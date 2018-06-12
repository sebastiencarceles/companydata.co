# frozen_string_literal: true

require "rails_helper"

RSpec.describe Billing::SignWorker, type: :worker do
  let(:user) { create :user }
  let(:proabono) { double :proabono }
  subject { Billing::SignWorker.new.perform(user.id) }

  it "calls Proabono to sign user" do
    expect(Proabono).to receive(:new).with(user).and_return(proabono)
    expect(proabono).to receive(:sign)
    subject
  end
end
