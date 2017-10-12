# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }
  it { should validate_uniqueness_of(:slug) }
  it { should callback(:set_slug).before(:save).if(:name_changed?) }
  it { should callback(:set_linkedin_id).before(:save).if(:linkedin_url_changed?) }

  describe "#set_slug" do
    let(:company_1) { FactoryGirl.create :company, name: "virgin" }
    let(:company_2) { FactoryGirl.create :company, name: "virgin" }
    let(:company_3) { FactoryGirl.create :company, name: "Virgin" }

    context "when multiple companies have the same name" do
      it "remains unique" do
        expect(company_1.slug).not_to eq company_2.slug
        expect(company_2.slug).to eq "virgin-1"
      end
    end

    context "when multiple companies have the same name with different case" do
      it "remains unique" do
        expect(company_1.slug).not_to eq company_3.slug
        expect(company_3.slug).to eq "virgin-1"
      end
    end
  end

  describe "#set_linkedin_id" do
    let(:company) { FactoryGirl.create :company }

    it "is correctly set" do
      expect(company.linkedin_id).to eq company.linkedin_url.split("/").last.to_i
    end
  end
end
