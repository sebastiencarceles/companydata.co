# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }
  it { should validate_uniqueness_of(:slug) }
  it { should validate_inclusion_of(:quality).in_array(Company::QUALITIES).allow_blank(true) }
  it { should callback(:set_slug).before(:validation).if(:name?).unless(:slug?) }
  it { should callback(:set_founded_in).before(:save).if(:founded_at?).unless(:founded_in?) }
  it { should callback(:set_headquarter_in).before(:save).if(:quality? && :city?).unless(:headquarter_in?) }

  let(:registration_1) { "rego" }

  describe "#headquarter" do
    context "when the company is a headquarter" do
      before { subject.update(quality: "headquarter") }

      it "returns self" do
        expect(subject.headquarter).to eq(subject)
      end
    end

    context "when the company is a branch" do
      it "returns the headquarter when it exists" do
        headquarter = FactoryGirl.create :company, quality: "headquarter", registration_1: registration_1, registration_2: "1"
        subject.update(quality: "branch", registration_1: registration_1, registration_2: "2")
        expect(subject.headquarter).to eq(headquarter)
      end

      it "returns nil otherwise" do
        expect(subject.headquarter).to be_nil
      end
    end
  end

  describe "#branches" do
    context "when the company is a headquarter" do
      before { subject.update(quality: "headquarter", registration_1: registration_1, registration_2: "1") }

      it "returns the branches when any" do
        branch_1 = FactoryGirl.create :company, quality: "branch", registration_1: registration_1, registration_2: "2"
        branch_2 = FactoryGirl.create :company, quality: "branch", registration_1: registration_1, registration_2: "3"
        expect(subject.branches.to_a).to eq([branch_1, branch_2])
      end

      it "returns an empty association otherwise" do
        expect(subject.branches).to be_empty
      end
    end

    context "when the company is a branch" do
      before { subject.update(quality: "branch", registration_1: registration_1, registration_2: "1") }

      it "returns the other branches when any" do
        branch_1 = FactoryGirl.create :company, quality: "branch", registration_1: registration_1, registration_2: "2"
        branch_2 = FactoryGirl.create :company, quality: "branch", registration_1: registration_1, registration_2: "3"
        expect(subject.branches.to_a).to eq([branch_1, branch_2])
      end

      it "returns an empty association otherwise" do
        expect(subject.branches).to be_empty
      end
    end
  end

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

  describe "#set_founded_in" do
    subject { FactoryGirl.create :company, founded_at: 900.days.ago, founded_in: nil }

    it "sets founded in from founded at" do
      expect(subject.founded_in).to eq(900.days.ago.year.to_s)
    end
  end

  describe "#set_headquarter_in" do
    subject { FactoryGirl.create :company, quality: "headquarter", headquarter_in: nil }

    it "sets headquarter_in from city when the company is the headquarter" do
      expect(subject.headquarter_in).to eq(subject.city)
    end
  end
end
