# frozen_string_literal: true

require "rails_helper"

RSpec.describe Billing::IncrementWorker, type: :worker do
  let(:counter_value) { 77 }
  let(:user) { create :user }
  let(:proabono) { double :proabono }
  subject { Billing::IncrementWorker.new.perform(user.id, counter_value) }

  before { allow(Proabono).to receive(:new).with(user).and_return(proabono) }
  it "calls Proabono to increment usage" do
    expect(proabono).to receive(:increment_by).with(counter_value).and_return(Code: nil)
    subject
  end

  it "sends emails when the user has no active subscription" do
    allow(proabono).to receive(:increment_by).with(counter_value).and_return(Code: "Error.Api.Usage.NoneMatching")
    expect { subject }.to change { Sidekiq::Worker.jobs.size }.by(1)
    expect(Sidekiq::Worker.jobs.last["args"][0]["arguments"]).to eq ["UserMailer", "no_subscription", "deliver_now", user.id]
  end

  it "sends emails when the user has no paying method" # TODO https://docs.proabono.com/fr/integration-synchroniser-votre-service-avec-proabono-5/

  it "sends emails when the user has unpaid invoices" # TODO https://docs.proabono.com/fr/integration-synchroniser-votre-service-avec-proabono-5/
end
