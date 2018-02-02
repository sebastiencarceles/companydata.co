# frozen_string_literal: true

class Api::CompanySerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :slug,
    :source_url,
    :headquarter_in,
    :founded_in,
    :legal_form,
    :staff,
    :specialities,
    :presentation,
    :logo_url,
    :registration_1,
    :registration_2,
    :activity_code,
    :activity,
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
    :founded_at,
    :geolocation,
    :country,
    :quality,
    :revenue,
    :smooth_name,
    :financial_years

  def activity
    return object.category if object.activity_code.blank?
    "#{I18n.t("activity_codes.#{object.activity_code}")}"
  end
end
