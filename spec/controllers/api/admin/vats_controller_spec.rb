# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Admin::VatsController, type: :request do
  describe "Getting a Vat to check with GET /to_check" do
    it "returns http unauthorized when unauthenticated" do
      get "/api/admin/vats/to_check"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns http unauthorized when authenticated with a non admin" do
      get "/api/admin/vats/to_check", headers: authentication_header
      expect(response).to have_http_status(:unauthorized)
    end

    context "when authenticated with an admin" do
      context "when there is a vat to check" do
        let!(:vat) { create(:company, registration_1: "123456789").vat }
        subject { get "/api/admin/vats/to_check", headers: admin_authentication_header }

        it "returns http success" do
          subject
          expect(response).to be_success
        end

        it "returns the corresponding Vat" do
          subject
          expect(parsed_body["id"]).to eq vat.id
        end

        it "sets the Vat to status in_progress" do
          expect { subject }.to change { vat.reload.status }.from("waiting_for_validation").to("in_progress")
        end
      end

      context "when there is no vat to check" do
        subject { get "/api/admin/vats/to_check", headers: admin_authentication_header }

        it "returns no content" do
          subject
          expect(response).to have_http_status :no_content
        end
      end
    end
  end

  describe "Setting a Vat number status with PATCH /vats/<value>" do
    let!(:vat) { create(:company, registration_1: "123456789").vat }

    it "returns http unauthorized when unauthenticated" do
      patch "/api/admin/vats/#{vat.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns http unauthorized when authenticated with a non admin" do
      patch "/api/admin/vats/#{vat.id}", headers: authentication_header
      expect(response).to have_http_status(:unauthorized)
    end

    context "when authenticated with an admin" do
      context "when the Vat can't be found" do
        subject { patch "/api/admin/vats/totoro", headers: admin_authentication_header }

        it "returns http not found" do
          subject
          expect(response).to have_http_status :not_found
        end
      end

      context "when the Vat can be found" do
        subject { patch "/api/admin/vats/#{vat.id}", params: { vat: { status: "valid" } }, headers: admin_authentication_header }

        it "returns http success" do
          subject
          expect(response).to be_success
        end
      end
    end
  end
end
