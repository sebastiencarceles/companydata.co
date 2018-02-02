# frozen_string_literal: true

FactoryBot.define do
  factory :financial_year do
    currency "€"
    revenue 1
    income 1
    staff 1
    duration 1
    closing_date "2018-01-23"
    company
  end
end
