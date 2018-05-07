# frozen_string_literal: true

class Api::V1::CompanySerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :slug,
    :legal_form,
    :staff,
    :presentation,
    :logo_url,
    :activity,
    :address,
    :founded_at,
    :country,
    :country_code,
    :quality,
    :smooth_name,
    :headquarter_id,
    :branch_ids

  def address
    object.address_components.join(", ")
  end

  def headquarter_id
    object.headquarter.try(:id)
  end

  def branch_ids
    object.branches.map(&:id)
  end
end
