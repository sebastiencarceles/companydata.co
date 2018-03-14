# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CompaniesController, type: :request do
  describe "Getting a company with GET /api/v1/companies/[:identifier]" do
    context "when unauthenticated" do
      before { get "/api/v1/companies/3323344" }

      it { expect(response).to have_http_status :unauthorized }
    end

    context "when authenticated" do
      context "when the company can't be found" do
        before { get "/api/v1/companies/3323344", headers: authentication_header }

        it { expect(response).to have_http_status :not_found }
      end

      context "when the company is found" do
        let(:company) { create :company, registration_1: "828022153", registration_2: "00016" }

        context "by id" do
          before { get "/api/v1/companies/#{company.id}", headers: authentication_header }

          it { expect(response).to be_success }

          it "returns the company" do
            expect(parsed_body["id"]).to eq company.id
          end

          it "returns full companies" do
            expect(parsed_body.keys.sort).to eq([
              "id",
              "name",
              "slug",
              "source_url",
              "legal_form",
              "staff",
              "specialities",
              "presentation",
              "logo_url",
              "registration_1",
              "registration_2",
              "activity_code",
              "activity",
              "address",
              "address_line_1",
              "address_line_2",
              "address_line_3",
              "address_line_4",
              "address_line_5",
              "cedex",
              "zipcode",
              "city",
              "department_code",
              "department",
              "region",
              "founded_at",
              "geolocation",
              "country",
              "quality",
              "revenue",
              "smooth_name",
              "financial_years",
              "vat_number"
            ].sort)
          end
        end

        context "by slug" do
          before { get "/api/v1/companies/#{company.slug}", headers: authentication_header }

          it { expect(response).to be_success }

          it "returns the company" do
            expect(parsed_body["id"]).to eq company.id
          end
        end

        context "by registration number" do
          context "when there is only one company with this registration number" do
            before { get "/api/v1/companies/#{company.registration_1}", headers: authentication_header }

            it { expect(response).to be_success }

            it "returns the company" do
              expect(parsed_body["id"]).to eq company.id
              expect(Company.where(registration_1: company.registration_1).count).to eq 1
            end
          end

          context "when there are multiple companies with this registration number" do
            context "when there is a headquarter" do
              let!(:company_hq) { create :company, quality: "headquarter", registration_1: company.registration_1, registration_2: "00002" }
              let!(:company_3) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00003" }
              before {
                company.update!(quality: "branch")
                get "/api/v1/companies/#{company.registration_1}", headers: authentication_header
              }

              it { expect(response).to be_success }

              it "returns the headquarter company" do
                expect(parsed_body["id"]).to eq company_hq.id
                expect(Company.where(registration_1: company.registration_1).count).to eq 3
              end
            end

            context "when there is no headquarter" do
              let!(:company_2) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00002" }
              let!(:company_3) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00003" }
              before {
                company.update!(quality: "branch")
                get "/api/v1/companies/#{company.registration_1}", headers: authentication_header
              }

              it { expect(response).to be_success }

              it "returns a branch" do
                expect(parsed_body["id"]).to eq company.id
                expect(Company.where(registration_1: company.registration_1).count).to eq 3
              end
            end
          end
        end
      end
    end
  end

  describe "Getting a company with GET /api/v1/companies/[:registration_1]/[:registration_2]" do
    context "when unauthenticated" do
      before { get "/api/v1/companies/3323344/12345" }

      it { expect(response).to have_http_status :unauthorized }
    end

    context "when authenticated" do
      context "when the company can't be found" do
        before { get "/api/v1/companies/3323344/123456", headers: authentication_header }

        it { expect(response).to have_http_status :not_found }
      end

      context "when the company is found" do
        let(:company) { create :company, registration_1: "828022153", registration_2: "00016" }

        before { get "/api/v1/companies/#{company.registration_1}/#{company.registration_2}", headers: authentication_header }

        it { expect(response).to be_success }

        it "returns the company" do
          expect(parsed_body["id"]).to eq company.id
        end
      end
    end
  end

  describe "Searching for companies with GET /api/v1/companies/" do
    context "when unauthenticated" do
      before { get "/api/v1/companies/" }

      it { expect(response).to have_http_status :unauthorized }
    end

    context "when authenticated" do
      context "when the query is not given" do
        before { get "/api/v1/companies/", headers: authentication_header }

        it { expect(response).to have_http_status :bad_request }
      end

      context "when the query is given" do
        context "without pagination parameter" do
          before { get "/api/v1/companies", params: { q: "total" }, headers: authentication_header }

          it { expect(response).to be_success }

          it "returns a collection of companies" do
            expect(parsed_body.map { |body| body["name"] }).to eq ["total", "totali", "motal"]
          end
        end

        context "with pagination parameters" do
          it "returns the asked page" do
            get "/api/v1/companies", params: { q: "company", page: 1 }, headers: authentication_header
            first_page = parsed_body.map { |body| body["name"] }

            get "/api/v1/companies", params: { q: "company", page: 2 }, headers: authentication_header
            second_page = parsed_body.map { |body| body["name"] }

            expect(first_page & second_page).to be_empty
          end

          it "returns the asked quantity" do
            get "/api/v1/companies", params: { q: "company", per_page: 5 }, headers: authentication_header
            expect(parsed_body.count).to eq(5)
          end
        end

        it "returns the pagination data in the response headers" do
          get "/api/v1/companies", params: { q: "company", page: 2, per_page: 5 }, headers: authentication_header
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
