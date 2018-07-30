# frozen_string_literal: true

class Api::V1::CompanySerializer < Api::V1::Serializer
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

  [
    :legal_form,
    :staff,
    :presentation,
    :logo_url,
    :activity,
    :founded_at,
    :country,
    :country_code,
    :quality
  ].each do |attribute_name|
    define_method(attribute_name) do
      sandboxize(:company, object, attribute_name)
    end
  end

  def address
    if sandbox?
      build_fake(:company).address_components.join(", ")
    else
      object.address_components.join(", ")
    end
  end

  def headquarter_id
    object.headquarter.try(:id)
  end

  def branch_ids
    object.branches.map(&:id)
  end
end
