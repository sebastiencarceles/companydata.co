require 'rails_helper'

RSpec.describe Counter, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:value) }
  it { should validate_numericality_of(:value).is_greater_than_or_equal_to(0) }

  let(:counter) { create :counter }

  describe "#increment_value!" do
    it "increments the value by 1" do
      expect { counter.increment_value! }.to change { counter.reload.value }.by(1)
    end
  end

  describe '#bill!' do
    it "sets the counter as billed" do
      expect { counter.bill! }.to change { counter.reload.billed }.from(false).to(true)
    end
  end
end
