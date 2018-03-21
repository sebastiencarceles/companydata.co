# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name Faker::Company.name
    logo_url "http://fr.seaicons.com/wp-content/uploads/2015/08/green-ok-icon.png"
    website Faker::Internet.url
    source_url "https://www.linkedin.com/company/1234"
    linkedin_id 1
    legal_form "Limited"
    category "Retail"
    staff "1-10 employees"
    presentation Faker::Lorem.paragraphs
    country "France"
    quality "headquarter"

    # Note: This should be the last trait in the list so `reindex` is called after all the other callbacks complete.
    trait :reindex do
      after(:create) do |company, _evaluator|
        company.reindex(refresh: true)
      end
    end
  end

  factory :full_company, class: Company do
    name Faker::Company.name
    website Faker::Internet.url
    source_url "https://www.linkedin.com/company/1234"
    legal_form "Limited"
    staff "1-10 employees"
    category "Retail"
    presentation Faker::Lorem.paragraphs
    logo_url "http://fr.seaicons.com/wp-content/uploads/2015/08/green-ok-icon.png"
    registration_1 "828022053"
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
    lat Faker::Address.latitude
    lng Faker::Address.longitude
    quality "headquarter"
    revenue "1 to 5 billions USD"
    country "France"
    civility Faker::Name.prefix
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email Faker::Internet.email
    phone Faker::PhoneNumber.phone_number

    after :create do |company|
      create_list :financial_year, 3, company: company
    end
  end
end
