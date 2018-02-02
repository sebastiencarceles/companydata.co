# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::CompanySerializer, type: :serializer do
  before(:all) {
    @company = create :full_company
  }
  after(:all) {
    @company.destroy!
  }
  before {
    @company.reload
  }

  let(:serializer) { Api::CompanySerializer.new(@company) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:subject) { JSON.parse(serialization.to_json) }

  it "includes the expected attributes" do
    expect(subject.keys).to contain_exactly(
      "id",
      "name",
      "slug",
      "source_url",
      "headquarter_in",
      "founded_in",
      "legal_form",
      "staff",
      "specialities",
      "presentation",
      "logo_url",
      "registration_1",
      "registration_2",
      "activity_code",
      "activity",
      "address_line_1",
      "address_line_2",
      "address_line_3",
      "address_line_4",
      "address_line_5",
      "cedex",
      "zipcode",
      "city",
      "department_code",
      "department",
      "region",
      "founded_at",
      "geolocation",
      "country",
      "quality",
      "revenue",
      "smooth_name"
    )
  end

  it { expect(subject["id"]).not_to be_nil }
  it { expect(subject["name"]).not_to be_nil }
  it { expect(subject["slug"]).not_to be_nil }
  it { expect(subject["source_url"]).not_to be_nil }
  it { expect(subject["headquarter_in"]).not_to be_nil }
  it { expect(subject["founded_in"]).not_to be_nil }
  it { expect(subject["legal_form"]).not_to be_nil }
  it { expect(subject["staff"]).not_to be_nil }
  it { expect(subject["specialities"]).not_to be_nil }
  it { expect(subject["presentation"]).not_to be_nil }
  it { expect(subject["logo_url"]).not_to be_nil }
  it { expect(subject["registration_1"]).not_to be_nil }
  it { expect(subject["registration_2"]).not_to be_nil }
  it { expect(subject["activity_code"]).not_to be_nil }
  it { expect(subject["activity"]).not_to be_nil }
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
  it { expect(subject["founded_at"]).not_to be_nil }
  it { expect(subject["geolocation"]).not_to be_nil }
  it { expect(subject["country"]).not_to be_nil }
  it { expect(subject["quality"]).not_to be_nil }
  it { expect(subject["revenue"]).not_to be_nil }
  it { expect(subject["smooth_name"]).not_to be_nil }

  it { expect(subject["id"]).to eql(@company.id) }
  it { expect(subject["name"]).to eql(@company.name) }
  it { expect(subject["slug"]).to eql(@company.slug) }
  it { expect(subject["source_url"]).to eql(@company.source_url) }
  it { expect(subject["headquarter_in"]).to eql(@company.headquarter_in) }
  it { expect(subject["founded_in"]).to eql(@company.founded_in) }
  it { expect(subject["legal_form"]).to eql(@company.legal_form) }
  it { expect(subject["staff"]).to eql(@company.staff) }
  it { expect(subject["specialities"]).to eql(@company.specialities) }
  it { expect(subject["presentation"]).to eql(@company.presentation) }
  it { expect(subject["logo_url"]).to eql(@company.logo_url) }
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
  it { expect(subject["founded_at"]).to eql(I18n.l(@company.founded_at)) }
  it { expect(subject["geolocation"]).to eql(@company.geolocation) }
  it { expect(subject["country"]).to eql(@company.country) }
  it { expect(subject["quality"]).to eql(@company.quality) }
  it { expect(subject["revenue"]).to eql(@company.revenue) }
  it { expect(subject["smooth_name"]).to eql(@company.smooth_name) }
  
  context "when there is an activity code" do
    it { expect(subject["activity"]).to eql("#{I18n.t("activity_codes.#{@company.activity_code}")}") }    
  end

  context "when there is no activity code" do
    before { @company.activity_code = nil }
    it { expect(subject["activity"]).to eql(@company.category) }        
  end

end
