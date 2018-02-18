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

      context "when user has no usage for the current month" do
        before { current_user.usages.delete_all }

        it "creates an usage" do
          expect { subject }.to change { current_user.usages.count }.by(1)
        end
      end

      User::PLANS.each do |plan, limit|
        context "when user has a #{plan} plan" do
          before {
            current_user.update!(plan: plan)
            subject
          }

          it "sets the limit to #{limit}" do
            expect(current_user.usages.last.limit).to eq(limit)
          end
        end
      end

      context "when user already has an usage for the current month" do
        before { current_user.usages << create(:usage, user: current_user) }

        it "does not create another usage" do
          expect { subject }.not_to change { current_user.usages.count }
        end
      end

      it "increments the usage api calls counter" do
        usage = create(:usage, user: current_user, count: 3)
        expect { subject }.to change { usage.reload.count }.by(1)
      end

      context "when the usage limit is reached" do
        before {
          usage = current_user.usages.last
          usage.update!(count: usage.limit)
          subject
        }

        it "returns http forbidden" do
          expect(response).to have_http_status(:forbidden)
        end

        it "returns a detailed error" do
          expect(parsed_body["error"]).to eq "plan limit reached"
        end
      end

      context "when the usage limit is 0" do
        before {
          current_user.update!(plan: User::PLANS.keys.last)
          subject
        }

        it "means that the limit can't be reached" do
          expect(current_user.usages.last.limit).to eq(0)
          expect(current_user.usages.last.count).to eq(1)
        end
      end
    end
  end
end
