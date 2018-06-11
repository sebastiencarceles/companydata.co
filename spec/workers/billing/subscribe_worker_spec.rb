require 'rails_helper'

RSpec.describe Billing::SubscribeWorker, type: :worker do
  let(:user) { create :user }
  let(:proabono) { double :proabono }
  subject { Billing::SubscribeWorker.new.perform(user.id) }

  it "calls Proabono to subscribe user" do
    expect(Proabono).to receive(:new).with(user).and_return(proabono)
    expect(proabono).to receive(:subscribe)
    subject
  end
end
