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

      context "when user has no counter for the current day" do
        before { current_user.counters.delete_all }

        it "creates an counter" do
          expect { subject }.to change { current_user.counters.count }.by(1)
          expect(current_user.reload.counters.last.date).to eq Date.today
        end
      end

      context "when user already has an counter for the current day" do
        before { current_user.counters << create(:counter, date: Date.today, user: current_user) }

        it "does not create another counter" do
          expect { subject }.not_to change { current_user.counters.count }
        end
      end

      it "increments the counter api calls counter" do
        counter = create(:counter, date: Date.today, user: current_user, value: 77)
        expect { subject }.to change { counter.reload.value }.by(1)
      end
    end
  end
end
