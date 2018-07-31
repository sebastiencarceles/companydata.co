# frozen_string_literal: true

class Api::V1::FullCompanySerializer < Api::V1::CompanySerializer
  attributes :source_url,
    :registration_1,
    :registration_2,
    :activity_code,
    :address_line_1,
    :address_line_2,
    :address_line_3,
    :address_line_4,
    :address_line_5,
    :cedex,
    :zipcode,
    :city,
    :department_code,
    :department,
    :region,
    :geolocation,
    :revenue,
    :vat_number,
    :prefix,
    :email,
    :phone,
    :website,
    :facebook,
    :linkedin,
    :twitter,
    :crunchbase
  has_many :financial_years

  [
    :source_url,
    :registration_1,
    :registration_2,
    :activity_code,
    :address_line_1,
    :address_line_2,
    :address_line_3,
    :address_line_4,
    :address_line_5,
    :cedex,
    :zipcode,
    :city,
    :department_code,
    :department,
    :region,
    :geolocation,
    :revenue,
    :email,
    :phone,
    :website,
    :facebook,
    :linkedin,
    :twitter,
    :crunchbase
  ].each do |attribute_name|
    define_method(attribute_name) do
      sandboxize(:full_company, object, attribute_name)
    end
  end

  def prefix
    if sandbox?
      FactoryBot.build(:full_company).civility
    else
      object.civility
    end
  end

  def vat_number
    if sandbox?
      company = FactoryBot.build(:full_company)
      key = ((12 + 3 * (company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
      "#{company.country_code}#{key}#{company.registration_1}"
    else
      object.vat_number
    end
  end
end
