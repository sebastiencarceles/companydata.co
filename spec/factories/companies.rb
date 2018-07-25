# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    logo_url { Faker::Company.logo }
    website { Faker::Internet.url }
    source_url { Faker::Internet.url }
    legal_form { Faker::Company.type }
    category { Faker::Company.industry }
    staff "1-10 employees"
    presentation Faker::Lorem.paragraphs
    country { Faker::Address.country }
    country_code { Faker::Address.country_code }
    quality { Company::QUALITIES.sample }

    # Note: This should be the last trait in the list so `reindex` is called after all the other callbacks complete.
    trait :reindex do
      after(:create) do |company, _evaluator|
        company.reindex(refresh: true)
      end
    end
  end

  factory :full_company, class: Company do
    name { Faker::Company.name }
    website { Faker::Internet.url }
    source_url { Faker::Internet.url }
    legal_form { Faker::Company.type }
    staff "1-10 employees"
    category { Faker::Company.industry }
    presentation { Faker::Lorem.paragraphs }
    logo_url { Faker::Company.logo }
    registration_1 { Faker::Company.french_siren_number }
    registration_2 { Faker::Number.number(5) }
    activity_code { %w(0899Z 6201Z 2011Z 2550B 4213A 4645Z).sample }
    address_line_1 { Faker::Address.street_address }
    address_line_2 { Faker::Address.secondary_address }
    address_line_3 { Faker::Address.community }
    address_line_4 { Faker::Address.secondary_address }
    address_line_5 { Faker::Address.secondary_address }
    cedex { Faker::Address.zip_code }
    zipcode { Faker::Address.zip_code }
    city { Faker::Address.city }
    department_code "69"
    department "Nouveau Rhône"
    region "Rhône-Alpes"
    founded_at "2013-06-06"
    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
    quality { Company::QUALITIES.sample }
    revenue "1 to 5 billions USD"
    country "France"
    country_code "FR"
    civility { Faker::Name.prefix }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    facebook { Faker::Internet.url("facebook.com", "/mycompany") }
    twitter { Faker::Internet.url("twitter.com", "/mycompany") }
    linkedin { Faker::Internet.url("linkedin.com", "/mycompany") }
    crunchbase { Faker::Internet.url("crunchbase.com", "/mycompany") }

    after :create do |company|
      create_list :financial_year, 3, company: company
    end
  end
end
