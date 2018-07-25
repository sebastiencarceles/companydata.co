# frozen_string_literal: true

class Api::V1::VatSerializer < Api::V1::Serializer
  attributes :value, :country_code, :status, :validated_at
  belongs_to :company

  [:value, :country_code, :status, :validated_at].each do |attribute_name|
    define_method(attribute_name) do
      sandboxize(object, attribute_name)
    end
  end
end
