# frozen_string_literal: true

class Api::Admin::VatSerializer < ActiveModel::Serializer
  attributes :id, :company_id, :value, :country_code, :status
end
