# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CompanySerializer, type: :serializer do
  before(:all) {
    @company = create :full_company
    @other_branches = []
    @other_branches << create(:full_company, registration_1: @company.registration_1, registration_2: "abc", quality: "branch")
    @other_branches << create(:full_company, registration_1: @company.registration_1, registration_2: "def", quality: "branch")
  }
  after(:all) {
    @company.destroy!
    @other_branches.each { |branch| branch.destroy! }
  }
  before { @company.reload }

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
      "presentation",
      "logo_url",
      "activity",
      "address",
      "founded_at",
      "country",
      "country_code",
      "quality",
      "smooth_name",
      "headquarter_id",
      "branch_ids"
    )
  end

  it { expect(subject["id"]).not_to be_nil }
  it { expect(subject["name"]).not_to be_nil }
  it { expect(subject["slug"]).not_to be_nil }
  it { expect(subject["legal_form"]).not_to be_nil }
  it { expect(subject["staff"]).not_to be_nil }
  it { expect(subject["presentation"]).not_to be_nil }
  it { expect(subject["logo_url"]).not_to be_nil }
  it { expect(subject["activity"]).not_to be_nil }
  it { expect(subject["address"]).not_to be_nil }
  it { expect(subject["founded_at"]).not_to be_nil }
  it { expect(subject["country"]).not_to be_nil }
  it { expect(subject["country_code"]).not_to be_nil }
  it { expect(subject["quality"]).not_to be_nil }
  it { expect(subject["smooth_name"]).not_to be_nil }
  it { expect(subject["branch_ids"]).not_to be_nil }
  it { expect(subject["branch_ids"]).not_to be_empty }

  it { expect(subject["id"]).to eql(@company.id) }
  it { expect(subject["name"]).to eql(@company.name) }
  it { expect(subject["slug"]).to eql(@company.slug) }
  it { expect(subject["legal_form"]).to eql(@company.legal_form) }
  it { expect(subject["staff"]).to eql(@company.staff) }
  it { expect(subject["presentation"]).to eql(@company.presentation) }
  it { expect(subject["logo_url"]).to eql(@company.logo_url) }
  it { expect(subject["founded_at"]).to eql(I18n.l(@company.founded_at, format: "%Y-%m-%d")) }
  it { expect(subject["country"]).to eql(@company.country) }
  it { expect(subject["country_code"]).to eql(@company.country_code) }
  it { expect(subject["quality"]).to eql(@company.quality) }
  it { expect(subject["smooth_name"]).to eql(@company.smooth_name) }
  it { expect(subject["branch_ids"]).to eql @other_branches.map(&:id) }


  describe "activity" do
    context "when there is an activity code" do
      it { expect(subject["activity"]).to eql("#{I18n.t("activity_codes.#{@company.activity_code}")}") }
    end

    context "when there is no activity code" do
      before { @company.activity_code = nil }
      it { expect(subject["activity"]).to eql(@company.category) }
    end
  end

  describe "headquarter_id" do
    context "when the company is a headquarter" do
      it { expect(subject["headquarter_id"]).to be_nil }
    end

    context "when the company is a branch" do
      before(:all) { @headquarter = create :full_company, quality: "headquarter", registration_1: @company.registration_1 }
      after(:all) { @headquarter.destroy! }
      before { @company.update!(quality: "branch") }

      it { expect(subject["headquarter_id"]).not_to be_nil }
      it { expect(subject["headquarter_id"]).to eql @company.headquarter.id }
    end
  end
end
