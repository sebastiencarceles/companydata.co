# frozen_string_literal: true

class Api::V1::Serializer < ActiveModel::Serializer
  protected
    def sandbox?
      instance_options[:sandbox].present?
    end

    def build_fake
      FactoryBot.build(object.class.name.underscore.to_sym)
    end

    def sandboxize(object, attribute_name)
      if sandbox?
        build_fake.send(attribute_name)
      else
        object.send(attribute_name)
      end
    end
end
