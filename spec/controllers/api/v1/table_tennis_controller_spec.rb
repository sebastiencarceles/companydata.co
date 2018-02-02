# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::TableTennisController, type: :request do
  describe "Getting a ping with GET /ping" do
    context "when unauthenticated" do
      before { get "/api/v1/ping" }

      it "returns http unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error detail" do
        expect(parsed_body["error"]).to eq "unauthenticated or unauthorized user"
      end
    end

    context "when authenticated" do
      before { get "/api/v1/ping", headers: authentication_header }

      it "returns http success" do
        expect(response).to be_success
      end

      it "returns authenticated pong" do
        expect(parsed_body["response"]).to eq "pong"
      end
    end
  end
end
