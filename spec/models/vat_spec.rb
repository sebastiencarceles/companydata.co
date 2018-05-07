# frozen_string_literal: true

require "rails_helper"

RSpec.describe Vat, type: :model do
  it { should belong_to(:company) }
  it { should validate_presence_of(:company) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:country_code) }
  it { should validate_inclusion_of(:status).in_array(Vat::STATUSES) }
  it { should callback(:set_value).before(:validation).unless(:value?) }

  describe "#set_value" do
    let(:company) { create :company }

    it "sets value when country code is FR" do
      company.country_code = "FR"
      company.registration_1 = "123456789"
      key = ((12 + 3 * (company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
      value = "FR#{key}#{company.registration_1}"
      expect { company.save! }.to change { Vat.count }.by(1)
      expect(Vat.last.value).to eq value
    end

    it "sets value when country code is BE" do
      company.country_code = "BE"
      company.registration_1 = "0400.139.153"
      expect { company.save! }.to change { Vat.count }.by(1)
      expect(Vat.last.value).to eq "BE0400139153"
    end

    it "does not set value otherwise" do
      company.country_code = "GB"
      company.registration_1 = "123456789"
      expect { company.save! }.not_to change { Vat.count }
    end
  end
end
