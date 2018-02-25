# frozen_string_literal: true

class Api::V1::CompanySerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :slug,
    :legal_form,
    :staff,
    :specialities,
    :presentation,
    :logo_url,
    :activity,
    :address,
    :founded_at,
    :country,
    :quality,
    :revenue,
    :smooth_name

  def activity
    return object.category if object.activity_code.blank?
    "#{I18n.t("activity_codes.#{object.activity_code}")}"
  end

  def address
    object.address_components.join(", ")
  end
end
