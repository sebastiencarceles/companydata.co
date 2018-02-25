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
    :vat_number
  has_many :financial_years
end
