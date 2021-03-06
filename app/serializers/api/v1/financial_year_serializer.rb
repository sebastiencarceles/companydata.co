# frozen_string_literal: true

class Api::V1::FinancialYearSerializer < Api::V1::Serializer
  attributes :year,
    :currency,
    :revenue,
    :income,
    :staff,
    :duration,
    :closing_date

  [
    :currency,
    :revenue,
    :income,
    :staff,
  ].each do |attribute_name|
    define_method(attribute_name) do
      sandboxize(:financial_year, object, attribute_name)
    end
  end
end
