require 'rails_helper'

RSpec.describe Api::CompanySerializer, type: :serializer do
  before(:all) {
    @company = FactoryGirl.create :company
  }
  after(:all) {
    @company.destroy!
  }
  let(:serializer) { Api::CompanySerializer.new(@company) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

  let(:subject) { JSON.parse(serialization.to_json) }

  it "includes the expected attributes" do
    expect(subject.keys).to contain_exactly(
      "id",
      "name",
      "slug",
      "website"
    )
  end

  it { expect(subject["id"]).to eql(@company.id) }

  
end