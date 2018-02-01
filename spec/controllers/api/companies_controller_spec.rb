# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::CompaniesController, type: :request do
  describe "Getting a company with GET /api/companies/[:identifier]" do
    context "when unauthenticated" do
      before { get "/api/companies/3323344" }

      it "returns http unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do

      context "when the company can't be found" do
        before { get "/api/companies/3323344", headers: authentication_header }

        it "returns http not found" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the company is found" do
        let(:company) { FactoryGirl.create :company }

        context "by id" do
          before { get "/api/companies/#{company.id}", headers: authentication_header }

          it "returns http success" do
            expect(response).to be_success
          end

          it "returns the company" do
            expect(parsed_body["id"]).to eq company.id
          end
        end

        context "by slug" do
          before { get "/api/companies/#{company.slug}", headers: authentication_header }

          it "returns http success" do
            expect(response).to be_success
          end

          it "returns the company" do
            expect(parsed_body["id"]).to eq company.id
          end
        end

        context "by name" do
          before { get "/api/companies/#{company.name.parameterize}", headers: authentication_header }

          it "returns http success" do
            expect(response).to be_success
          end

          it "returns the company" do
            expect(parsed_body["id"]).to eq company.id
          end
        end

        context "by smooth name" do
          before { get "/api/companies/#{company.smooth_name.parameterize}", headers: authentication_header }

          it "returns http success" do
            expect(response).to be_success
          end

          it "returns the company" do
            expect(parsed_body["id"]).to eq company.id
          end
        end
      end
    end
  end

  describe "Searching for companies with GET /api/companies/" do
    context "when unauthenticated" do
      before { get "/api/companies/" }

      it "returns http unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      context "when the query is not given" do
        before { get "/api/companies/", headers: authentication_header }

        it "returns http bad request" do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when the query is given" do
        before {
          FactoryGirl.create :company, :reindex, name: "totali"
          FactoryGirl.create :company, :reindex, name: "tube metal"
          FactoryGirl.create :company, :reindex, name: "total"
          FactoryGirl.create :company, :reindex, name: "edf"
          FactoryGirl.create :company, :reindex, name: "motal"
          get "/api/companies", params: { q: "total" }, headers: authentication_header
        }

        it "returns http success" do
          expect(response).to be_success
        end

        it "returns a collection of companies" do
          expect(parsed_body.map { |body| body["name"] }).to eq ["total", "totali", "motal"]
        end
      end
    end
  end
end
