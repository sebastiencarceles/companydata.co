# frozen_string_literal: true

FactoryBot.define do
  factory :vat do
    company
    value "FR000111222"
    status "valid"
    validated_at DateTime.now
    country_code "FR"
  end
end
