# frozen_string_literal: true

class Activity < ApplicationRecord
  validates_presence_of :country_code, :code, :label_fr
  validates_uniqueness_of :country_code, scope: :code
end
