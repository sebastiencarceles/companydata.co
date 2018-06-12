# frozen_string_literal: true

require "rails_helper"

RSpec.describe Billing::IncrementWorker, type: :worker do
  let(:user) { create :user }
  let(:proabono) { double :proabono }
  subject { Billing::IncrementWorker.new.perform(user.id, 77) }

  it "calls Proabono to increment usage" do
    expect(Proabono).to receive(:new).with(user).and_return(proabono)
    expect(proabono).to receive(:increment_by).with(77)
    subject
  end

  it "sends emails when the user has no active subscription" # TODO https://docs.proabono.com/fr/integration-synchroniser-votre-service-avec-proabono-5/

  it "sends emails when the user has no paying method" # TODO https://docs.proabono.com/fr/integration-synchroniser-votre-service-avec-proabono-5/

  it "sends emails when the user has unpaid invoices" # TODO https://docs.proabono.com/fr/integration-synchroniser-votre-service-avec-proabono-5/
end
