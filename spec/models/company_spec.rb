# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }
  it { should validate_uniqueness_of(:slug) }
  it { should callback(:set_slug).before(:validation).if(:name_changed?) }
  it { should callback(:set_founded_in).before(:save).if(:founded_at_changed?) }

  
  describe "#set_slug" do
    let(:company_1) { FactoryGirl.create :company, name: "virgin" }
    let(:company_2) { FactoryGirl.create :company, name: "virgin" }
    let(:company_3) { FactoryGirl.create :company, name: "Virgin" }
    
    context "when multiple companies have the same name" do
      it "remains unique" do
        expect(company_1.slug).not_to eq company_2.slug
        expect(company_2.slug).to eq "virgin-1"
      end
    end
    
    context "when multiple companies have the same name with different case" do
      it "remains unique" do
        expect(company_1.slug).not_to eq company_3.slug
        expect(company_3.slug).to eq "virgin-1"
      end
    end
  end
  
  describe "#set_founded_in" do
    subject { FactoryGirl.create :company }
    
    it "sets founded in from founded at" do
      founded_at = 900.days.ago
      expect { subject.update(founded_at: founded_at) }.to change { subject.reload.founded_in }.to(founded_at.year.to_s)
    end
  end
end
