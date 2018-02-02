require 'rails_helper'

RSpec.describe Usage, type: :model do
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:year) }
  it { should validate_presence_of(:month) }
  it { should validate_presence_of(:count) }
  it { should validate_presence_of(:limit) }
end
