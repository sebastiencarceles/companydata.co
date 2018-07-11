# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::VatsController, type: :request do
  describe "Getting a Vat with GET /api/v1/vats/[:value]" do
    context "when unauthenticated" do
      before { get "/api/v1/vats/FR123456789" }

      it { expect(response).to have_http_status :unauthorized }
    end

    context "when authenticated" do
      context "when sandbox" do
        before { get "/api/v1/vats/FR123456789", headers: authentication_header(sandbox: true) }

        it { expect(response).to be_success }

        it "returns a sandbox VAT" do
          expect(parsed_body["value"]).to eq "FR123456789"
        end
      end

      context "when not sandbox" do
        it "returns a not_found when the Vat can't be found" do
          get "/api/v1/vats/FR123456789", headers: authentication_header
          expect(response).to have_http_status :not_found
        end

        describe "when the Vat exists" do
          let!(:vat) { create(:company, registration_1: "123456789").vat }

          before { get "/api/v1/vats/#{vat.value}", headers: authentication_header }

          it { expect(response).to be_success }

          it "returns the Vat" do
            expect(parsed_body["value"]).to eq vat.value
          end
        end
      end
    end
  end
end
