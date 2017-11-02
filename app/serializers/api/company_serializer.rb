# frozen_string_literal: true

class Api::CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :website
end
