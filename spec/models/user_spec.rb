# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it { should have_many(:counters) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_acceptance_of(:terms_of_service) }
  it { should callback(:sign).after(:create) }
  it { should callback(:subscribe).after(:create) }
  it { should callback(:track_creation).after(:create) }
  it { should callback(:track_update).after(:create) }

  let(:user) { build :user }

  describe "sign" do
    context "after create" do
      it "starts the sign worker" do
        expect { user.save! }.to change { Billing::SignWorker.jobs.size }.by(1)
        expect(Billing::SignWorker).to have_enqueued_sidekiq_job(user.id)
      end
    end
  end

  describe "subscribe" do
    context "after create" do
      it "starts the subscription worker" do
        expect { user.save! }.to change { Billing::SubscribeWorker.jobs.size }.by(1)
        expect(Billing::SubscribeWorker).to have_enqueued_sidekiq_job(user.id)
      end
    end
  end
end
