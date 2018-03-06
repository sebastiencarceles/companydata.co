# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email Faker::Internet.email
    password Faker::Internet.password
    terms_of_service true
  end
end
