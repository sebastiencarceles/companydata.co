# frozen_string_literal: true

FactoryBot.define do
  factory :vat do
    company { create :company, registration_1: "123456789", country: "France" }
    country_code "FR"
  end
end
