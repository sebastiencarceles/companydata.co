# frozen_string_literal: true

class Company < ApplicationRecord
  searchkick

  QUALITIES = %w[headquarter branch]

  has_many :financial_years, -> { order(year: :desc) }, dependent: :destroy

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  validates_inclusion_of :quality, in: QUALITIES, allow_blank: true

  before_validation :set_slug, if: :name?, unless: :slug?
  before_save :set_founded_in, if: :founded_at?, unless: :founded_in?
  before_save :set_headquarter_in, if: :quality? && :city?, unless: :headquarter_in?
  before_save :set_smooth_name, if: :name?, unless: :smooth_name?

  scope :headquarters, -> { where(quality: "headquarter") }
  scope :branchs, -> { where(quality: "branch") }

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

    def set_founded_in
      self.founded_in = founded_at.year
    end

    def set_headquarter_in
      self.headquarter_in = city if headquarter? && city.present?
    end

    def set_smooth_name
      self.smooth_name = name.gsub("*", " ").gsub("/", " ").titleize.strip
    end
end
