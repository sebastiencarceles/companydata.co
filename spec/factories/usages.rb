# frozen_string_literal: true

FactoryBot.define do
  factory :usage do
    user
    year Date.today.year
    month Date.today.month
    count 0
  end
end
