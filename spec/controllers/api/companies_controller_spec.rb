# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::CompaniesController, type: :request do
  describe "getting a company" do
    context "when the company can't be found" do
      before { get "/api/companies/3323344" }

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the company is found" do
      let(:company) { FactoryGirl.create :company }

      context "by id" do
        before { get "/api/companies/#{company.id}" }

        it "returns http success" do
          expect(response).to be_success
        end

        it "returns the company" do
          expect(parsed_body["id"]).to eq company.id
        end
      end

      context "by slug" do
        before { get "/api/companies/#{company.slug}" }

        it "returns http success" do
          expect(response).to be_success
        end

        it "returns the company" do
          expect(parsed_body["id"]).to eq company.id
        end
      end

      context "by name" do
        before { get "/api/companies/#{company.name.parameterize}" }

        it "returns http success" do
          expect(response).to be_success
        end

        it "returns the company" do
          expect(parsed_body["id"]).to eq company.id
        end
      end
    end
  end

  describe "searching for companies" do
    context "when the query is not given" do
      before { get "/api/companies/" }

      it "returns http bad request" do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when the query is given" do
      before { get "/api/companies", params: { q: "something" } }

      it "returns http success" do
        expect(response).to be_success
      end

      it "returns a collection of companies"
    end
  end
end
