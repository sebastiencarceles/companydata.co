# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinancialYear, type: :model do
  it { should validate_presence_of(:company) }
  it { should validate_inclusion_of(:currency).in_array(FinancialYear::CURRENCIES) }

end
