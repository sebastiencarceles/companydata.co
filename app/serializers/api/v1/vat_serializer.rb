# frozen_string_literal: true

class Api::V1::VatSerializer < ActiveModel::Serializer
  attributes :value, :country_code, :status, :validated_at, :company
end
