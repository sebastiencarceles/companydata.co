# frozen_string_literal: true

class Usage < ApplicationRecord
  belongs_to :user

  validates_presence_of :user, :year, :month, :count, :limit
end
