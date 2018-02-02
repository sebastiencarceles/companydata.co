# frozen_string_literal: true

FactoryGirl.define do
  factory :company do
    name Faker::Company.name
    logo_url "http://fr.seaicons.com/wp-content/uploads/2015/08/green-ok-icon.png"
    website Faker::Internet.url
    source_url "https://www.linkedin.com/company/1234"
    linkedin_id 1
    headquarter_in Faker::Address.city
    legal_form "Limited"
    category "Retail"
    staff "1-10 employees"
    specialities Faker::Lorem.paragraph
    presentation Faker::Lorem.paragraphs

    # Note: This should be the last trait in the list so `reindex` is called after all the other callbacks complete.
    trait :reindex do
      after(:create) do |company, _evaluator|
        company.reindex(refresh: true)
      end
    end
  end

  factory :full_company, class: "Company" do
    name Faker::Company.name
    website Faker::Internet.url
    source_url "https://www.linkedin.com/company/1234"
    headquarter_in Faker::Address.city
    legal_form "Limited"
    staff "1-10 employees"
    category "Retail"
    specialities Faker::Lorem.paragraph
    presentation Faker::Lorem.paragraphs
    logo_url "http://fr.seaicons.com/wp-content/uploads/2015/08/green-ok-icon.png"
    registration_1 "123456789"
    registration_2 "00015"
    activity_code "6201Z"
    address_line_1 Faker::Address.street_address
    address_line_2 Faker::Address.secondary_address
    address_line_3 Faker::Address.community
    address_line_4 Faker::Address.secondary_address
    address_line_5 Faker::Address.secondary_address
    cedex Faker::Address.zip_code
    zipcode Faker::Address.zip_code
    city Faker::Address.city
    department_code "69"
    department "Nouveau Rhône"
    region "Rhône-Alpes"
    founded_at "2013-06-06"
    geolocation "#{Faker::Address.latitude}, #{Faker::Address.longitude}"
    country Faker::Address.country
    quality "headquarter"
    revenue "1 to 5 billions USD"
  end
end
