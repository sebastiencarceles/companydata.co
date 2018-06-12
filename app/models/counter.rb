# frozen_string_literal: true

class Counter < ApplicationRecord
  belongs_to :user

  validates_presence_of :date, :value
  validates_numericality_of :value, greater_than_or_equal_to: 0

  def increment_value!
    increment!(:value)
  end

  def bill!
    self.update(billed: true)
  end
end
