# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    firstname Faker::Name.first_name
    lastname Faker::Name.last_name
    email Faker::Internet.email
    password Faker::Internet.password
  end
end
