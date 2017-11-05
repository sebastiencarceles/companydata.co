# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::UserTokenController, type: :request do
  describe "creating a token" do

    context "when the credentials are valid" do
      let(:user) { FactoryGirl.create :user }
      let(:auth_params) { { auth: { email: user.email, password: user.password } } }

      before { post "/api/user_token", params: auth_params }

      it "returns http success" do
        expect(response).to be_success
      end

      it "returns a JWT" do
        expect(parsed_body["jwt"]).not_to eq nil
      end

      context "when the credentials are invalid" do
        before { post "/api/user_token", params: { auth: { email: "fake@fake.com", password: "passwor" } } }

        it "returns http not found" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
