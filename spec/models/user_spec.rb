# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it { should have_many(:usages) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_inclusion_of(:plan).in_array(User::PLANS.keys.map(&:to_s)) }

  describe "plans and usage" do
    let(:user) { build :user }

    context "after creation" do
      it "creates an usage" do
        expect { user.save! }.to change { user.usages.count }.by(1)
      end

      it "has the corresponding limit" do
        user.save!
        expect(user.usages.last.limit).to eq(user.plan_limit)
      end

      it "has the current year and month" do
        user.save!
        expect(user.usages.last.year).to eq(Date.today.year)
        expect(user.usages.last.month).to eq(Date.today.month)
      end
    end

    context "when the plan is changed" do
      let(:user) { create :user }

      context "when there is no usage" do
        before { user.usages.delete_all }

        it "creates a usage" do
          expect { user.update!(plan: User::PLANS.keys.last) }.to change { user.usages.count }.by(1)
        end

        it "has the corresponding limit" do
          user.update!(plan: User::PLANS.keys.last)
          expect(user.usages.last.limit).to eq(user.plan_limit)
        end
      end

      context "when there is a current usage" do
        let!(:usage) { create :usage, user: user }

        it "does not create an usage" do
          expect { user.update!(plan: User::PLANS.keys.last) }.not_to change { user.usages.count }
        end

        it "updates it's limit" do
          user.update!(plan: User::PLANS.keys.last)
          expect(usage.reload.limit).to eq(user.plan_limit)
        end
      end
    end
  end
end
