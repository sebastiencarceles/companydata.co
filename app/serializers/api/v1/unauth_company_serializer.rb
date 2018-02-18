# frozen_string_literal: true

class Api::V1::UnauthCompanySerializer < ActiveModel::Serializer
  attributes :id,
    :smooth_name,
    :name,
    :slug,
    :website_url,
    :api_url

    def id
      return object.id
    end

    def name
      return object.name
    end

    def smooth_name
      return object.smooth_name
    end

    def website_url
      "https://www.companydata.co/companies/#{object.slug}"
    end

    def api_url
      "https://www.companydata.co/api/v1/companies/#{object.slug}"
    end
end
