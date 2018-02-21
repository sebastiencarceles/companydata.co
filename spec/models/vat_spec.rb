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
    let(:vat) { build :vat }

    it "does not set value when country code is not FR" do
      vat.country_code = "GB"
      expect(vat.save).to eq(false)
    end

    it "sets value when country code is FR" do
      key = ((12 + 3 * (vat.company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
      value = "FR#{key}#{vat.company.registration_1}"
      expect { vat.save! }.to change { vat.value }.from(nil).to(value)
    end
  end
end
