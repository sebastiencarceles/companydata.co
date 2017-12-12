# frozen_string_literal: true

class Company < ApplicationRecord
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  before_validation :set_slug, if: :name?, unless: :slug?
  before_save :set_founded_in, if: :founded_at_changed?

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
end
