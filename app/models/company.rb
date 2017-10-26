# frozen_string_literal: true

class Company < ApplicationRecord
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  before_validation :set_slug, if: :name_changed?
  before_save :set_founded_in, if: :founded_at_changed?

  def set_slug
    return unless name
    id, slug = 1, name.parameterize
    while Company.exists?(slug: slug) do
      slug = name.parameterize.strip + "-" + id.to_s
      id += 1
    end
    self.slug = slug
  end

  def set_founded_in
    self.founded_in = founded_at.year
  end
end
