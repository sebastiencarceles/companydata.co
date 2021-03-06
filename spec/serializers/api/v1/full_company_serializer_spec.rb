# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FullCompanySerializer, type: :serializer do
  it { expect(described_class).to be < Api::V1::CompanySerializer }

  before(:all) { @company = create :full_company, registration_1: "828022053", country: "France", country_code: "FR" }
  after(:all) { @company.destroy! }
  before { @company.reload }

  let(:serializer) { Api::V1::FullCompanySerializer.new(@company) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:subject) { JSON.parse(serialization.to_json) }

  it { expect(subject["source_url"]).not_to be_nil }
  it { expect(subject["registration_1"]).not_to be_nil }
  it { expect(subject["registration_2"]).not_to be_nil }
  it { expect(subject["activity_code"]).not_to be_nil }
  it { expect(subject["address_line_1"]).not_to be_nil }
  it { expect(subject["address_line_2"]).not_to be_nil }
  it { expect(subject["address_line_3"]).not_to be_nil }
  it { expect(subject["address_line_4"]).not_to be_nil }
  it { expect(subject["address_line_5"]).not_to be_nil }
  it { expect(subject["cedex"]).not_to be_nil }
  it { expect(subject["zipcode"]).not_to be_nil }
  it { expect(subject["city"]).not_to be_nil }
  it { expect(subject["department_code"]).not_to be_nil }
  it { expect(subject["department"]).not_to be_nil }
  it { expect(subject["region"]).not_to be_nil }
  it { expect(subject["geolocation"]).not_to be_nil }
  it { expect(subject["vat_number"]).not_to be_nil }
  it { expect(subject["revenue"]).not_to be_nil }
  it { expect(subject["prefix"]).not_to be_nil }
  it { expect(subject["email"]).not_to be_nil }
  it { expect(subject["phone"]).not_to be_nil }
  it { expect(subject["website"]).not_to be_nil }
  it { expect(subject["facebook"]).not_to be_nil }
  it { expect(subject["linkedin"]).not_to be_nil }
  it { expect(subject["twitter"]).not_to be_nil }
  it { expect(subject["crunchbase"]).not_to be_nil }
  it { expect(subject["country_code"]).not_to be_nil }
  it { expect(subject["financial_years"]).not_to be_nil }
  it { expect(subject["financial_years"][0]["year"]).not_to be_nil }
  it { expect(subject["financial_years"][0]["currency"]).not_to be_nil }
  it { expect(subject["financial_years"][0]["revenue"]).not_to be_nil }
  it { expect(subject["financial_years"][0]["income"]).not_to be_nil }
  it { expect(subject["financial_years"][0]["staff"]).not_to be_nil }
  it { expect(subject["financial_years"][0]["duration"]).not_to be_nil }
  it { expect(subject["financial_years"][0]["closing_date"]).not_to be_nil }

  it { expect(subject["source_url"]).to eql(@company.source_url) }
  it { expect(subject["registration_1"]).to eql(@company.registration_1) }
  it { expect(subject["registration_2"]).to eql(@company.registration_2) }
  it { expect(subject["activity_code"]).to eql(@company.activity_code) }
  it { expect(subject["address_line_1"]).to eql(@company.address_line_1) }
  it { expect(subject["address_line_2"]).to eql(@company.address_line_2) }
  it { expect(subject["address_line_3"]).to eql(@company.address_line_3) }
  it { expect(subject["address_line_4"]).to eql(@company.address_line_4) }
  it { expect(subject["address_line_5"]).to eql(@company.address_line_5) }
  it { expect(subject["cedex"]).to eql(@company.cedex) }
  it { expect(subject["zipcode"]).to eql(@company.zipcode) }
  it { expect(subject["city"]).to eql(@company.city) }
  it { expect(subject["department_code"]).to eql(@company.department_code) }
  it { expect(subject["department"]).to eql(@company.department) }
  it { expect(subject["region"]).to eql(@company.region) }
  it { expect(subject["founded_at"]).to eql(I18n.l(@company.founded_at, format: "%Y-%m-%d")) }
  it { expect(subject["geolocation"]).to eql(@company.geolocation) }
  it { expect(subject["vat_number"]).to eql(@company.vat_number) }
  it { expect(subject["revenue"]).to eql(@company.revenue) }
  it { expect(subject["prefix"]).to eql(@company.civility) }
  it { expect(subject["email"]).to eql(@company.email) }
  it { expect(subject["phone"]).to eql(@company.phone) }
  it { expect(subject["website"]).to eql(@company.website) }
  it { expect(subject["facebook"]).to eql(@company.facebook) }
  it { expect(subject["linkedin"]).to eql(@company.linkedin) }
  it { expect(subject["twitter"]).to eql(@company.twitter) }
  it { expect(subject["crunchbase"]).to eql(@company.crunchbase) }
  it { expect(subject["country_code"]).to eql(@company.country_code) }
  it { expect(subject["financial_years"].length).to eq(@company.financial_years.count) }
  it { expect(subject["financial_years"][0]["year"]).to eql(@company.financial_years.first.year) }
  it { expect(subject["financial_years"][0]["currency"]).to eql(@company.financial_years.first.currency) }
  it { expect(subject["financial_years"][0]["revenue"]).to eql(@company.financial_years.first.revenue) }
  it { expect(subject["financial_years"][0]["income"]).to eql(@company.financial_years.first.income) }
  it { expect(subject["financial_years"][0]["staff"]).to eql(@company.financial_years.first.staff) }
  it { expect(subject["financial_years"][0]["duration"]).to eql(@company.financial_years.first.duration) }
  it { expect(subject["financial_years"][0]["closing_date"]).to eql(I18n.l(@company.financial_years.first.closing_date, format: "%Y-%m-%d")) }
end
