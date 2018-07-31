# frozen_string_literal: true

FactoryBot.define do
  factory :financial_year do
    currency "€"
    revenue { rand(10000..1000000) }
    income { rand(1000..10000) }
    staff { rand(1..200) }
    duration 12
    closing_date "2018-01-23"
    year "2018"
    company
  end
end
