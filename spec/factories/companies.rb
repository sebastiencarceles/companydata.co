# frozen_string_literal: true

FactoryGirl.define do
  factory :company do
    name Faker::Company.name
    logo_url "http://fr.seaicons.com/wp-content/uploads/2015/08/green-ok-icon.png"
    website Faker::Internet.url
    source_url "https://www.linkedin.com/company/1234"
    linkedin_id 1
    headquarter_in Faker::Address.city
    founded_in "2017"
    company_type "Limited"
    category "Retail"
    staff "1-10 employees"
    specialities Faker::Lorem.paragraph
    presentation Faker::Lorem.paragraphs
  end
end
