# frozen_string_literal: true

class FinancialYear < ApplicationRecord
  CURRENCIES = %w[$ €]

  belongs_to :company

  validates_presence_of :company
  validates_inclusion_of :currency, in: CURRENCIES
end
