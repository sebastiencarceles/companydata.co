class Vat < ApplicationRecord
  belongs_to :company

  STATUSES = %w[in_progress validated invalidates]

  validates_presence_of :company, :vat_number, :status
  validates_inclusion_of :status, in: STATUSES
end
