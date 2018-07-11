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
    :name,
    :legal_form,
    :staff,
    :presentation,
    :logo_url,
    :activity,
    :founded_at,
    :country,
    :country_code,
    :quality,
    :smooth_name
  ].each do |attribute_name|
    define_method(attribute_name) do
      sandboxize(object.send(attribute_name))
    end
  end

  def address
    sandboxize(object.address_components.join(", "))
  end

  def headquarter_id
    object.headquarter.try(:id)
  end

  def branch_ids
    object.branches.map(&:id)
  end
end
