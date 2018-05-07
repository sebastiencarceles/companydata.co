# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  it { should have_many(:financial_years) }
  it { should have_one(:vat) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:country) }
  it { should validate_presence_of(:country_code) }
  it { should validate_uniqueness_of(:slug) }
  it { should validate_inclusion_of(:quality).in_array(Company::QUALITIES).allow_blank(true) }
  it { should callback(:set_slug).before(:validation).if(:should_set_slug?) }
  it { should callback(:set_smooth_name).before(:validation).if(:should_set_smooth_name?) }
  it { should callback(:set_vat!).after(:save).if(:should_set_vat?) }
  it { should delegate_method(:vat_number).to(:vat) }

  let(:registration_1) { "rego" }

  describe "#headquarter" do
    context "when the company is a headquarter" do
      before { subject.update(quality: "headquarter") }

      it "returns nil" do
        expect(subject.headquarter).to be_nil
      end
    end

    context "when the company is a branch" do
      it "returns the headquarter when it exists" do
        headquarter = create :company, quality: "headquarter", registration_1: registration_1, registration_2: "1"
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
        branch_1 = create :company, quality: "branch", registration_1: registration_1, registration_2: "2"
        branch_2 = create :company, quality: "branch", registration_1: registration_1, registration_2: "3"
        expect(subject.branches.to_a).to eq([branch_1, branch_2])
      end

      it "returns an empty association otherwise" do
        expect(subject.branches).to be_empty
      end
    end

    context "when the company is a branch" do
      before { subject.update(quality: "branch", registration_1: registration_1, registration_2: "1") }

      it "returns the other branches when any" do
        branch_1 = create :company, quality: "branch", registration_1: registration_1, registration_2: "2"
        branch_2 = create :company, quality: "branch", registration_1: registration_1, registration_2: "3"
        expect(subject.branches.to_a).to eq([branch_1, branch_2])
      end

      it "returns an empty association otherwise" do
        expect(subject.branches).to be_empty
      end
    end
  end

  describe "#set_slug" do
    let(:company_1) { create :company, name: "virgin" }
    let(:company_2) { create :company, name: "virgin" }
    let(:company_3) { create :company, name: "Virgin" }

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

    context "when a company has - as name" do
      it "can't be created" do
        expect(build(:company, name: "-").save).to eq false
      end
    end
  end

  describe "#set_smooth_name" do
    let(:company) { build :company, name: "JANOT*THIERRY/" }

    it "sets the smooth name" do
      expect { company.save! }.to change { company.smooth_name }.from(nil).to("Janot Thierry")
    end
  end

  describe "#set_vat!" do
    context "when the country is France" do
      let(:company) { build :company, country: "France", country_code: "FR", registration_1: "123456789" }

      it "creates a Vat with the correct country code" do
        expect { company.save! }.to change { Vat.count }.by(1)
        expect(company.vat.id).to eq(Vat.last.id)
        expect(company.vat.country_code).to eq("FR")
      end
    end

    context "when the country is Belgium" do
      let(:company) { build :company, country: "Belgium", country_code: "BE", registration_1: "123456789" }

      it "creates a Vat with the correct country code" do
        expect { company.save! }.to change { Vat.count }.by(1)
        expect(company.vat.id).to eq(Vat.last.id)
        expect(company.vat.country_code).to eq("BE")
      end
    end
    
    it "does not create a Vat otherwise" do
      company = build :company, country: "Spain", country_code: "ES", registration_1: "123456789"
      expect { company.save! }.not_to change { Vat.count }
    end
  end
end
