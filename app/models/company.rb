# frozen_string_literal: true

class Company < ApplicationRecord
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  before_save :set_slug, if: :name_changed?
  before_save :set_linkedin_id, if: :linkedin_url_changed?

  def set_slug
    id, slug = 1, name.parameterize
    while Company.exists?(slug: slug) do
      slug = name.parameterize.strip + "-" + id.to_s
      id += 1
    end
    self.slug = slug
  end

  def set_linkedin_id
    self.linkedin_id = linkedin_url.split("/").last.to_i
  end
end
