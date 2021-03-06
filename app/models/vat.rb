# frozen_string_literal: true

class Vat < ApplicationRecord
  belongs_to :company

  STATUSES = %w[waiting_for_validation valid invalid in_progress]

  before_validation :set_value, unless: :value?

  validates_presence_of :company, :value, :status, :country_code
  validates_inclusion_of :status, in: STATUSES

  def vat_number
    value if status == "valid"
  end

  def validate!
    return unless status == "waiting_for_validation" || status == "in_progress"

    if value.blank?
      set_value
      save
    end

    client = Savon.client(wsdl: "http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl")
    response = client.call(:check_vat, message: { vatNumber: value.gsub(country_code, ""), countryCode: country_code })
    status = response.body[:check_vat_response][:valid] ? "valid" : "invalid"
    update_columns(status: status, validated_at: DateTime.now)

    rescue Savon::SOAPFault => error
      Rails.logger.error error.to_hash
      Bugsnag.notify(error)
  end

  def set_value
    if country_code == "FR"
      key = ((12 + 3 * (company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
      self.value = "FR#{key}#{company.registration_1}"
    elsif country_code == "BE"
      self.value = "BE#{company.registration_1.gsub(".", "")}"
    end
  end
end
