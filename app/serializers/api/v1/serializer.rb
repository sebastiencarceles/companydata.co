# frozen_string_literal: true

class Api::V1::Serializer < ActiveModel::Serializer
  protected
    def sandboxize(value)
      return nil if value.nil?
      return value if instance_options[:sandbox].blank?
      return 42 if value.is_a?(Integer)
      return Date.today if value.is_a?(Date)
      return DateTime.now if value.is_a?(DateTime)
      return Time.now if value.is_a?(Time)
      return value.gsub(/[a-zA-Z]/, "*").gsub(/[0-9]/, "#") if value.length < 5
      "#{value[0...4]}#{value[4..-1]&.gsub(/[a-zA-Z]/, '*')&.gsub(/[0-9]/, '#')}"
    end

    def sandboxize_hardly(value)
      return nil if value.nil?
      "***"
    end
end
