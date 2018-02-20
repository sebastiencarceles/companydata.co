# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UnauthCompaniesController, type: :request do
  describe "Autocompleting company names with GET /api/v1/companies/autocomplete" do
    context "when the query is not given" do
      before { get "/api/v1/companies/autocomplete" }

      it "returns http bad request" do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when the query is given" do
      before { get "/api/v1/companies/autocomplete", params: { q: "total" } }

      it "returns http success" do
        expect(response).to be_success
      end

      it "returns a collection of companies" do
        expect(parsed_body.map { |body| body["name"] }).to eq ["total", "totali", "motal"]
      end

      it "returns incomplete companies" do
        expect(parsed_body.first.keys.sort).to eq(["id", "name", "smooth_name", "website_url", "api_url", "city", "country"].sort)
      end
    end
  end
end
