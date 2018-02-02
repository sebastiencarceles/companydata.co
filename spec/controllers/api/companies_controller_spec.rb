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
        let(:company) { create :company }

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
    before(:all) {
      (1..20).each do |index|
        create :company, :reindex, name: "company #{index.to_s.rjust(2, "0")}"
      end

      create :company, :reindex, name: "totali"
      create :company, :reindex, name: "tube metal"
      create :company, :reindex, name: "total"
      create :company, :reindex, name: "edf"
      create :company, :reindex, name: "motal"
    }

    after(:all) {
      Company.delete_all
    }

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
        context "without pagination parameter" do
          before { get "/api/companies", params: { q: "total" }, headers: authentication_header }

          it "returns http success" do
            expect(response).to be_success
          end

          it "returns a collection of companies" do
            expect(parsed_body.map { |body| body["name"] }).to eq ["total", "totali", "motal"]
          end
        end

        context "with pagination parameters" do
          it "returns the asked page" do
            get "/api/companies", params: { q: "company", page: 1 }, headers: authentication_header
            first_page = parsed_body.map { |body| body["name"] }

            get "/api/companies", params: { q: "company", page: 2 }, headers: authentication_header
            second_page = parsed_body.map { |body| body["name"] }

            expect(first_page & second_page).to be_empty
          end

          it "returns the asked quantity" do
            get "/api/companies", params: { q: "company", per_page: 5 }, headers: authentication_header
            expect(parsed_body.count).to eq(5)
          end
        end

        it "returns the pagination data in the response headers" do
          get "/api/companies", params: { q: "company", page: 2, per_page: 5 }, headers: authentication_header
          expect(response.headers["X-Pagination-Limit-Value"]).to eq(5)
          expect(response.headers["X-Pagination-Total-Pages"]).to eq(4)
          expect(response.headers["X-Pagination-Current-Page"]).to eq(2)
          expect(response.headers["X-Pagination-Next-Page"]).to eq(3)
          expect(response.headers["X-Pagination-Prev-Page"]).to eq(1)
          expect(response.headers["X-Pagination-First-Page"]).to be false
          expect(response.headers["X-Pagination-Last-Page"]).to be false
          expect(response.headers["X-Pagination-Out-Of-Range"]).to be false
        end
      end
    end
  end
end
