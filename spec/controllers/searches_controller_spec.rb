# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchesController, type: :controller do

  describe "GET #create" do
    let(:search) { build :search }

    subject { get :create, params: { search: search.attributes } }
    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "creates a Search" do
      expect { subject }.to change { Search.count }.by(1)
      expect(Search.last.query).to eq(search.query)
    end
  end

end
