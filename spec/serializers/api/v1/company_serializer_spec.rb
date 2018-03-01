# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CompanySerializer, type: :serializer do
  before(:all) {
    @company = create :full_company
  }
  after(:all) {
    @company.destroy!
  }
  before {
    @company.reload
  }

  let(:serializer) { Api::V1::CompanySerializer.new(@company) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:subject) { JSON.parse(serialization.to_json) }

  it "includes the expected attributes" do
    expect(subject.keys).to contain_exactly(
      "id",
      "name",
      "slug",
      "legal_form",
      "staff",
      "specialities",
      "presentation",
      "logo_url",
      "activity",
      "address",
      "founded_at",
      "country",
      "quality",
      "revenue",
      "smooth_name"
    )
  end

  it { expect(subject["id"]).not_to be_nil }
  it { expect(subject["name"]).not_to be_nil }
  it { expect(subject["slug"]).not_to be_nil }
  it { expect(subject["legal_form"]).not_to be_nil }
  it { expect(subject["staff"]).not_to be_nil }
  it { expect(subject["specialities"]).not_to be_nil }
  it { expect(subject["presentation"]).not_to be_nil }
  it { expect(subject["logo_url"]).not_to be_nil }
  it { expect(subject["activity"]).not_to be_nil }
  it { expect(subject["address"]).not_to be_nil }
  it { expect(subject["founded_at"]).not_to be_nil }
  it { expect(subject["country"]).not_to be_nil }
  it { expect(subject["quality"]).not_to be_nil }
  it { expect(subject["revenue"]).not_to be_nil }
  it { expect(subject["smooth_name"]).not_to be_nil }

  it { expect(subject["id"]).to eql(@company.id) }
  it { expect(subject["name"]).to eql(@company.name) }
  it { expect(subject["slug"]).to eql(@company.slug) }
  it { expect(subject["legal_form"]).to eql(@company.legal_form) }
  it { expect(subject["staff"]).to eql(@company.staff) }
  it { expect(subject["specialities"]).to eql(@company.specialities) }
  it { expect(subject["presentation"]).to eql(@company.presentation) }
  it { expect(subject["logo_url"]).to eql(@company.logo_url) }
  it { expect(subject["founded_at"]).to eql(I18n.l(@company.founded_at, format: "%Y-%m-%d")) }
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
