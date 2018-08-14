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
        let(:company) { create :full_company, registration_1: "828022153", registration_2: "00016" }

        context "by id" do
          before { get "/api/v1/companies/#{company.id}", headers: authentication_header }

          it { expect(response).to be_success }

          it "returns the company" do
            expect(parsed_body["id"]).to eq company.id
          end

          it "returns full companies" do
            expect(parsed_body.keys.count).to eq 43
          end

        end

        context "by id (sandboxed)" do
          before { get "/api/v1/companies/#{company.id}", headers: authentication_header(sandbox: true) }

          it "returns sandboxed data" do
            expect(parsed_body["presentation"]).not_to be nil
            expect(parsed_body["presentation"]).not_to eq company.presentation
          end
        end

        context "by slug" do
          before { get "/api/v1/companies/#{company.slug}", headers: authentication_header }

          it { expect(response).to be_success }

          it "returns the company" do
            expect(parsed_body["id"]).to eq company.id
          end
        end

        context "by slug (sandboxed)" do
          before { get "/api/v1/companies/#{company.slug}", headers: authentication_header(sandbox: true) }

          it "returns sandboxed data" do
            expect(parsed_body["presentation"]).not_to be nil
            expect(parsed_body["presentation"]).not_to eq company.presentation
          end
        end

        context "by vat number" do
          context "when there is only one company with this VAT number" do
            before { get "/api/v1/companies/#{company.vat.value}", headers: authentication_header }

            it { expect(response).to be_success }

            it "returns the company" do
              expect(parsed_body["id"]).to eq company.id
              expect(Vat.where(value: company.vat.value).count).to eq 1
            end
          end

          context "when there is only one company with this VAT number (sandboxed)" do
            before { get "/api/v1/companies/#{company.vat.value}", headers: authentication_header(sandbox: true) }

            it "returns sandboxed data" do
              expect(parsed_body["presentation"]).not_to be nil
              expect(parsed_body["presentation"]).not_to eq company.presentation
            end
          end

          context "when there are multiple companies with this VAT number" do
            context "when there is a headquarter" do
              let!(:company_hq) { create :company, quality: "headquarter", registration_1: company.registration_1, registration_2: "00002" }
              let!(:company_3) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00003" }
              before {
                company.update!(quality: "branch")
                get "/api/v1/companies/#{company.vat.value}", headers: authentication_header
              }

              it { expect(response).to be_success }

              it "returns the headquarter company" do
                expect(parsed_body["id"]).to eq company_hq.id
                expect(Vat.where(value: company.vat.value).count).to eq 3
              end
            end

            context "when there is a headquarter (sandboxed)" do
              let!(:company_hq) { create :company, quality: "headquarter", registration_1: company.registration_1, registration_2: "00002" }
              let!(:company_3) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00003" }
              before {
                company.update!(quality: "branch")
                get "/api/v1/companies/#{company.vat.value}", headers: authentication_header(sandbox: true)
              }

              it "returns sandboxed data" do
                expect(parsed_body["presentation"]).not_to be nil
                expect(parsed_body["presentation"]).not_to eq company.presentation
              end
            end

            context "when there is no headquarter" do
              let!(:company_2) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00002" }
              let!(:company_3) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00003" }
              before {
                company.update!(quality: "branch")
                get "/api/v1/companies/#{company.vat.value}", headers: authentication_header
              }

              it { expect(response).to be_success }

              it "returns a branch" do
                expect(parsed_body["id"]).to eq company.id
                expect(Vat.where(value: company.vat.value).count).to eq 3
              end
            end

            context "when there is no headquarter (sandboxed)" do
              let!(:company_2) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00002" }
              let!(:company_3) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00003" }
              before {
                company.update!(quality: "branch")
                get "/api/v1/companies/#{company.vat.value}", headers: authentication_header(sandbox: true)
              }

              it "returns sandboxed data" do
                expect(parsed_body["presentation"]).not_to be nil
                expect(parsed_body["presentation"]).not_to eq company.presentation
              end
            end
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

          context "when there is only one company with this registration number (sandbox)" do
            before { get "/api/v1/companies/#{company.registration_1}", headers: authentication_header(sandbox: true) }

            it "returns sandboxed data" do
              expect(parsed_body["presentation"]).not_to be nil
              expect(parsed_body["presentation"]).not_to eq company.presentation
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

            context "when there is a headquarter (sandboxed)" do
              let!(:company_hq) { create :company, quality: "headquarter", registration_1: company.registration_1, registration_2: "00002" }
              let!(:company_3) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00003" }
              before {
                company.update!(quality: "branch")
                get "/api/v1/companies/#{company.registration_1}", headers: authentication_header(sandbox: true)
              }

              it "returns sandboxed data" do
                expect(parsed_body["presentation"]).not_to be nil
                expect(parsed_body["presentation"]).not_to eq company.presentation
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

            context "when there is no headquarter (sandboxed)" do
              let!(:company_2) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00002" }
              let!(:company_3) { create :company, quality: "branch", registration_1: company.registration_1, registration_2: "00003" }
              before {
                company.update!(quality: "branch")
                get "/api/v1/companies/#{company.registration_1}", headers: authentication_header(sandbox: true)
              }

              it "returns sandboxed data" do
                expect(parsed_body["presentation"]).not_to be nil
                expect(parsed_body["presentation"]).not_to eq company.presentation
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

      context "when the company is found (sandboxed)" do
        let(:company) { create :company, registration_1: "828022153", registration_2: "00016" }

        before { get "/api/v1/companies/#{company.registration_1}/#{company.registration_2}", headers: authentication_header(sandbox: true) }

        it "returns sandboxed data" do
          expect(parsed_body["presentation"]).not_to be nil
          expect(parsed_body["presentation"]).not_to eq company.presentation
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
      context "without pagination parameter" do
        before { get "/api/v1/companies", params: { q: "total", quality: "headquarter" }, headers: authentication_header }

        it { expect(response).to be_success }

        it "returns a collection of companies" do
          expect(parsed_body.map { |body| body["name"] }).to eq ["total", "totallo"]
        end
      end

      context "without pagination parameter (sandboxed)" do
        before { get "/api/v1/companies", params: { q: "total" }, headers: authentication_header(sandbox: true) }

        it "returns sandboxed data" do
          parsed_body.each do |body|
            expect(parsed_body[0]["presentation"]).not_to be nil
          end
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
        get "/api/v1/companies", params: { q: "company", quality: "all", page: 2, per_page: 5 }, headers: authentication_header
        expect(response.headers["X-Pagination-Limit-Value"]).to eq(5)
        expect(response.headers["X-Pagination-Total-Pages"]).to eq(4)
        expect(response.headers["X-Pagination-Current-Page"]).to eq(2)
        expect(response.headers["X-Pagination-Next-Page"]).to eq(3)
        expect(response.headers["X-Pagination-Prev-Page"]).to eq(1)
        expect(response.headers["X-Pagination-First-Page"]).to be false
        expect(response.headers["X-Pagination-Last-Page"]).to be false
        expect(response.headers["X-Pagination-Out-Of-Range"]).to be false
      end

      describe "quality parameter" do
        context "without quality" do
          before { get "/api/v1/companies", params: { q: "total" }, headers: authentication_header }

          it { expect(response).to be_success }

          it { expect(parsed_body).not_to be_empty }

          it "returns a collection of headquarters" do
            expect(parsed_body.map { |body| body["quality"] }.uniq).to eq ["headquarter"]
          end
        end

        context "with 'headquarter' as quality" do
          before { get "/api/v1/companies", params: { q: "total", quality: "headquarter" }, headers: authentication_header }

          it { expect(response).to be_success }

          it { expect(parsed_body).not_to be_empty }

          it "returns a collection of headquarters" do
            expect(parsed_body.map { |body| body["quality"] }.uniq).to eq ["headquarter"]
          end
        end

        context "with 'branch' as quality" do
          before { get "/api/v1/companies", params: { q: "total", quality: "branch" }, headers: authentication_header }

          it { expect(response).to be_success }

          it { expect(parsed_body).not_to be_empty }

          it "returns a collection of branches" do
            expect(parsed_body.map { |body| body["quality"] }.uniq).to eq ["branch"]
          end
        end

        context "with 'all' as quality" do
          before { get "/api/v1/companies", params: { q: "total", quality: "all" }, headers: authentication_header }

          it { expect(response).to be_success }

          it { expect(parsed_body).not_to be_empty }

          it "returns a collection of headquarters and branches" do
            expect(parsed_body.map { |body| body["quality"] }.uniq.sort).to eq ["branch", "headquarter"]
          end
        end

        context "with something else as quality" do
          before { get "/api/v1/companies", params: { q: "total", quality: "something" }, headers: authentication_header }

          it { expect(response).to have_http_status :bad_request }
        end
      end

      describe "founded_from parameter" do
        context "when founded_from is given and there are results" do
          before { get "/api/v1/companies", params: { founded_from: "2017-01-01" }, headers: authentication_header }

          it { expect(response).to be_success }

          it { expect(parsed_body).not_to be_empty }

          it "returns a collection of companies founded from the given date" do
            Company.where(id: parsed_body.map { |body| body["id"] }).each do |company|
              expect(company.founded_at).to be >= Date.parse("2017-01-01")
            end
          end
        end

        context "when founded_from is given and there is no result" do
          before { get "/api/v1/companies", params: { founded_from: "2018-09-01" }, headers: authentication_header }

          it { expect(response).to be_success }

          it { expect(parsed_body).to be_empty }
        end
      end

      [
        {
          name: :activity_code,
          valid: "6201z",
          invalid: "6201y"
        },
        {
          name: :city,
          valid: "fronsac",
          invalid: "bordeaux"
        },
        {
          name: :zipcode,
          valid: "33126",
          invalid: "33000"
        },
        {
          name: :country,
          valid: "france",
          invalid: "india"
        },
        {
          name: :country_code,
          valid: "fr",
          invalid: "rc"
        }

      ].each do |filter|
        describe "#{filter[:name]} parameter" do
          context "when #{filter[:name]} is given and there are results" do
            before { get "/api/v1/companies", params: { "#{filter[:name]}": filter[:valid] }, headers: authentication_header }

            it { expect(response).to be_success }

            it { expect(parsed_body).not_to be_empty }

            it "returns a collection of companies with the right #{filter[:name]}" do
              expect(Company.where(id: parsed_body.map { |body| body["id"] }).pluck(filter[:name]).uniq.first.downcase).to eq filter[:valid]
            end
          end

          context "when #{filter[:name]} is given and there is no result" do
            before { get "/api/v1/companies", params: { "#{filter[:name]}": filter[:invalid] }, headers: authentication_header }

            it { expect(response).to be_success }

            it { expect(parsed_body).to be_empty }
          end
        end
      end
    end
  end
end
