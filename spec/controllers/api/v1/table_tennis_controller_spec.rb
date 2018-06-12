# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::TableTennisController, type: :request do
  describe "Getting a ping with GET /ping" do
    context "when unauthenticated" do
      before { get "/api/v1/ping" }

      it "returns http unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns a detailed error" do
        expect(parsed_body["error"]).to eq "unauthenticated user"
      end
    end

    context "when authenticated" do
      subject { get "/api/v1/ping", headers: authentication_header }

      it "returns http success" do
        subject
        expect(response).to be_success
      end

      it "returns authenticated pong" do
        subject
        expect(parsed_body["response"]).to eq "pong"
      end

      context "when user has no usage for the current day" do
        # TODO before { current_user.usages.delete_all }

        it "creates an usage" do
          # TODO expect { subject }.to change { current_user.usages.count }.by(1)
        end
      end

      context "when user already has an usage for the current day" do
        # TODO before { current_user.usages << create(:usage, user: current_user) }

        it "does not create another usage" do
          # TODO expect { subject }.not_to change { current_user.usages.count }
        end
      end

      it "increments the usage api calls counter" do
        # TODO usage = create(:usage, user: current_user, count: 3)
        # TODO expect { subject }.to change { usage.reload.count }.by(1)
      end
    end
  end
end
