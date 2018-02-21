# frozen_string_literal: true

class Vat < ApplicationRecord
  belongs_to :company

  STATUSES = %w[waiting_for_validation valid invalid]

  before_validation :set_value, unless: :value?

  validates_presence_of :company, :value, :status, :country_code
  validates_inclusion_of :status, in: STATUSES

  def vat_number
    I18n.t("activerecord.attributes.vat.vat_number.#{status}", value: value)
  end

  def validate!
    return unless status == "waiting_for_validation"

    client = Savon.client(wsdl: "http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl")
    response = client.call(:check_vat, message: { vatNumber: value.gsub(country_code, ""), countryCode: country_code })
    status = response.body[:check_vat_response][:valid] ? "valid" : "invalid"
    update_columns(status: status, validated_at: DateTime.now)
  end

  private

    def set_value
      return unless country_code == "FR"
      
      key = ((12 + 3 * (company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
      self.value = "FR#{key}#{company.registration_1}"
    end
end
