# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::TableTennisController, type: :request do
  describe "getting a pong response to a ping request" do
    context "when unauthenticated" do
      before { get "/api/ping" }

      it "returns http success" do
        expect(response).to be_success
      end

      it "returns unauthenticated pong" do
        expect(parsed_body["response"]).to eq "unauthenticated pong"
      end
    end

    context "when authenticated" do
      before { get "/api/ping", headers: authentication_header }

      it "returns http success" do
        expect(response).to be_success
      end

      it "returns authenticated pong" do
        expect(parsed_body["response"]).to eq "authenticated pong"
      end
    end
  end
end
