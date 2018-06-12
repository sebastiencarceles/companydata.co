require 'rails_helper'

RSpec.describe Counter, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:billed) }
  it { should validate_presence_of(:value) }
  it { should validate_numericality_of(:value).is_greater_than_or_equal_to(0) }
end
