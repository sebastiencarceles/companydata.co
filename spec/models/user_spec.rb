# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  # TODO it { should validate_presence_of(:firstname) }
  # TODO it { should validate_presence_of(:lastname) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of(:password) }
end
