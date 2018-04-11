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
    :first_name,
    :last_name,
    :email,
    :phone,
    :website,
    :facebook,
    :linkedin,
    :twitter,
    :crunchbase,
    :country_code
  has_many :financial_years

  def prefix
    object.civility
  end
end
