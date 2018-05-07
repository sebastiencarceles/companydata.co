# frozen_string_literal: true

class Company < ApplicationRecord
  searchkick word_start: [:smooth_name], filterable: [:quality, :activity_code, :city, :zipcode, :country, :country_code]

  QUALITIES = %w[headquarter branch]

  has_many :financial_years, -> { order(year: :desc) }, dependent: :destroy
  has_one :vat, dependent: :destroy

  validates_presence_of :name, :slug, :country, :country_code
  validates_uniqueness_of :slug
  validates_inclusion_of :quality, in: QUALITIES, allow_blank: true

  before_validation :set_slug, if: :should_set_slug?
  before_validation :set_smooth_name, if: :should_set_smooth_name?
  after_save :set_vat!, if: :should_set_vat?

  scope :headquarters, -> { where(quality: "headquarter") }
  scope :branchs, -> { where(quality: "branch") }

  def search_data
    {
      smooth_name: smooth_name,
      name: name,
      quality: quality&.downcase,
      activity_code: activity_code&.downcase,
      zipcode: zipcode&.downcase,
      city: city&.downcase,
      country: country&.downcase,
      country_code: country_code&.downcase
    }
  end

  def headquarter?
    quality == "headquarter"
  end

  def branch?
    quality == "branch"
  end

  def headquarter
    return nil if headquarter? || registration_1.nil?
    Company.headquarters.where(registration_1: registration_1).first
  end

  def branches
    return [] if registration_1.nil?
    Company.branchs.where(registration_1: registration_1).where.not(id: id)
  end

  def vat_number
    set_vat! if should_set_vat?
    vat&.validate!
    vat&.vat_number
  end

  def geolocation
    return [lat, lng].join(",") if lat.present? && lng.present?
    return nil if geolocalized_at.present?

    update_columns(geolocalized_at: DateTime.now)

    full_address = [address_line_1, address_line_2, address_line_3, zipcode, city, country].reject(&:blank?).join(", ")
    uri = URI.escape("https://maps.googleapis.com/maps/api/geocode/json?address=#{full_address}&key=#{Figaro.env.GOOGLE_API_KEY}")
    response = open(uri).read()
    results = JSON.parse(response)["results"]

    if results.any?
      lat = results.first["geometry"]["location"]["lat"]&.to_f
      lng = results.first["geometry"]["location"]["lng"]&.to_f

      if lat.present? && lng.present? && lat != 0 && lng != 0
        update_columns(lat: lat, lng: lng)
        return [lat, lng].join(",")
      end
    end
  end

  def address_components
    zc = cedex.present? ? cedex : zipcode
    city_suffix = cedex.present? ? " CEDEX" : ""
    [
      address_line_1,
      address_line_2,
      address_line_3,
      address_line_4,
      address_line_5,
      [zc, "#{city}#{city_suffix}"].join(" ")
    ].reject(&:blank?)
  end

  def activity
    activity = Activity.where(country_code: country_code, code: activity_code).first if country_code.present? && activity_code.present?
    activity ||= Activity.find_by_code(activity_code) if activity_code.present?
    activity&.label_fr
  end

  private

    def set_slug
      counter = 1
      slug = name.parameterize
      while Company.exists?(slug: slug) do
        slug = name.parameterize.strip + "-" + counter.to_s
        counter += 1
      end
      self.slug = slug
    end

    def set_smooth_name
      self.smooth_name = name.gsub("*", " ").gsub("/", " ").titleize.strip
    end

    def set_vat!
      create_vat!(country_code: country_code)
    end

    def should_set_slug?
      name.present? && slug.blank?
    end

    def should_set_smooth_name?
      name.present? && smooth_name.blank?
    end

    def should_set_vat?
      vat.nil? && country.present? && registration_1.present? && ["FR", "BE"].include?(country_code)
    end
end
