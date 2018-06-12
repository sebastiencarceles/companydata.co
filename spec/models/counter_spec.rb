# frozen_string_literal: true

require "rails_helper"

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

  describe "#bill!" do
    it "sets the counter as billed" do
      expect { counter.bill! }.to change { counter.reload.billed }.from(false).to(true)
    end
  end

  describe "#until_yesterday" do
    it "returns all the previous counters until those of yesterday (included)" do
      create :counter, date: Date.tomorrow
      create :counter, date: Date.today
      old_counter = create :counter, date: 15.days.ago
      yesterday_counter = create :counter, date: Date.yesterday
      expect(Counter.until_yesterday.pluck(:id).sort).to eq [old_counter.id, yesterday_counter.id].sort
    end
  end

  describe "#unbilled" do
    it "returns only unbilled counters" do
      unbilled = create :counter, billed: false
      create :counter, billed: true
      expect(Counter.unbilled.pluck(:id)).to eq [unbilled.id]
    end
  end
end
