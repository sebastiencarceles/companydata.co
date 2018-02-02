# frozen_string_literal: true

class Api::FinancialYearSerializer < ActiveModel::Serializer
  attributes :year,
    :currency,
    :revenue,
    :income,
    :staff,
    :duration,
    :closing_date
end
