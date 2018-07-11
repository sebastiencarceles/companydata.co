# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::VatsController, type: :request do
  describe "Getting a Vat with GET /api/v1/vats/[:value]" do
    context "when unauthenticated" do
      before { get "/api/v1/vats/FR123456789" }

      it { expect(response).to have_http_status :unauthorized }
    end

    context "when authenticated" do
      it "returns a not_found when the Vat can't be found" do
        get "/api/v1/vats/FR123456789", headers: authentication_header
        expect(response).to have_http_status :not_found
      end

      let!(:vat) { create(:company, registration_1: "123456789").vat }

      context "when the Vat exists" do

        before { get "/api/v1/vats/#{vat.value}", headers: authentication_header }

        it { expect(response).to be_success }

        it "returns the Vat" do
          expect(parsed_body["value"]).to eq vat.value
        end
      end

      context "when the Vat exists (sandboxed)" do
        before { get "/api/v1/vats/#{vat.value}", headers: authentication_header(sandbox: true) }

        it "returns obfuscated data" do
          expect(parsed_body["value"]).to include "#########"
        end
      end
    end
  end
end
