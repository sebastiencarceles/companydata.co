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
