# frozen_string_literal: true

FactoryGirl.define do
  factory :company do
    name Faker::Company.name
    slug Faker::Internet.slug
    website Faker::Internet.url
    linkedin_url "https://www.linkedin.com/company/1234"
    linkedin_id 1
    headquarter_in Faker::Address.city
    founded_in "2017"
    type "Limited"
    category "Retail"
    staff "1-10 employees"
    specialities Faker::Lorem.paragraph
    presentation Faker::Lorem.paragraphs
  end
end
