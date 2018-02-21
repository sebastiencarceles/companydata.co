require 'rails_helper'

RSpec.describe Vat, type: :model do
  it { should belong_to(:company) }
  it { should validate_presence_of(:company) }  
  it { should validate_presence_of(:vat_number) }
  it { should validate_presence_of(:status) }
  it { should validate_inclusion_of(:status).in_array(Vat::STATUSES) }
end
