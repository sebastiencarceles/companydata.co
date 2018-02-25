# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::LigthCompanySerializer, type: :serializer do
  before(:all) {
    @company = create :full_company
  }
  after(:all) {
    @company.destroy!
  }
  before {
    @company.reload
  }

  let(:serializer) { Api::V1::LigthCompanySerializer.new(@company) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:subject) { JSON.parse(serialization.to_json) }

  it "includes the expected attributes" do
    expect(subject.keys).to contain_exactly(
      "id",
      "smooth_name",
      "name",
      "website_url",
      "api_url",
      "city",
      "country"
    )
  end

  it { expect(subject["id"]).not_to be_nil }
  it { expect(subject["name"]).not_to be_nil }
  it { expect(subject["smooth_name"]).not_to be_nil }
  it { expect(subject["website_url"]).not_to be_nil }
  it { expect(subject["api_url"]).not_to be_nil }
  it { expect(subject["country"]).not_to be_nil }

  it { expect(subject["id"]).to eql(@company.id) }
  it { expect(subject["name"]).to eql(@company.name) }
  it { expect(subject["smooth_name"]).to eql(@company.smooth_name) }
  it { expect(subject["website_url"]).to eql("https://www.companydata.co/companies/#{@company.slug}") }
  it { expect(subject["api_url"]).to eql("https://www.companydata.co/api/v1/companies/#{@company.slug}") }
  it { expect(subject["city"]).to eql(@company.city) }
  it { expect(subject["country"]).to eql(@company.country) }
end
