# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::CompaniesController, type: :controller do
  describe "getting a company" do
    context "when the company can't be found" do
      it "returns http not found" do
        get :show, params: { identifier: 3325564 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the company is found" do
      let(:company) { FactoryGirl.create :company }

      context "by id" do
        it "returns http success" do
          get :show, params: { identifier: company.id }
          expect(response).to be_success
        end

        it "returns the company"
      end

      context "by slug" do
        it "returns http success" do
          get :show, params: { identifier: company.slug }
          expect(response).to be_success
        end

        it "returns the company"
      end

      context "by name" do
        it "returns http success" do
          get :show, params: { identifier: company.name }
          expect(response).to be_success
        end

        it "returns the company"
      end
    end
  end

  describe "searching for companies" do
    context "when the query is not given" do
      it "returns http bad request" do
        get :index
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when the query is given" do
      it "returns http success" do
        get :index, params: { q: "something" }
        expect(response).to be_success
      end

      it "returns a collection of companies"
    end
  end
end
