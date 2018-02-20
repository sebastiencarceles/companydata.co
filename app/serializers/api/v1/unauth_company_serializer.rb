# frozen_string_literal: true

class Api::V1::UnauthCompanySerializer < ActiveModel::Serializer
  attributes :id,
    :smooth_name,
    :name,
    :website_url,
    :api_url,
    :city,
    :country

  def id
    object.id
  end

  def name
    object.name
  end

  def smooth_name
    object.smooth_name
  end

  def website_url
    "https://www.companydata.co/companies/#{object.slug}"
  end

  def api_url
    "https://www.companydata.co/api/v1/companies/#{object.slug}"
  end

  def city
    object.city
  end

  def country
    object.country
  end
end
