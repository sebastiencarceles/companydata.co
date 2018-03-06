# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it { should have_many(:usages) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  describe "usage" do
    let(:user) { build :user }

    context "after creation" do
      it "creates an usage" do
        expect { user.save! }.to change { user.usages.count }.by(1)
      end

      it "has the current year and month" do
        user.save!
        expect(user.usages.last.year).to eq(Date.today.year)
        expect(user.usages.last.month).to eq(Date.today.month)
      end
    end
  end
end
