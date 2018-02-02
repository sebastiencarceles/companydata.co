# frozen_string_literal: true

class Api::V1::FinancialYearSerializer < ActiveModel::Serializer
  attributes :year,
    :currency,
    :revenue,
    :income,
    :staff,
    :duration,
    :closing_date
end
