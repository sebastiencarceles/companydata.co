class Counter < ApplicationRecord
  belongs_to :user

  validates_presence_of :date, :billed, :value
  validates_numericality_of :value, greater_than_or_equal_to: 0
end
