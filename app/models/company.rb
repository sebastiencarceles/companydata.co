# frozen_string_literal: true

class Company < ApplicationRecord
  searchkick

  QUALITIES = %w[headquarter branch]

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  validates_inclusion_of :quality, in: QUALITIES, allow_blank: true

  before_validation :set_slug, if: :name?, unless: :slug?
  before_save :set_founded_in, if: :founded_at?, unless: :founded_in?
  before_save :set_headquarter_in, if: :quality? && :city?, unless: :headquarter_in?

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
      self.headquarter_in = city if quality == "headquarter" && city.present?
    end
end
