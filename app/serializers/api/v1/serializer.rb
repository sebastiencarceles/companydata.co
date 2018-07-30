# frozen_string_literal: true

class Api::V1::Serializer < ActiveModel::Serializer
  protected
    def sandbox?
      instance_options[:sandbox].present?
    end

    def build_fake(factory)
      FactoryBot.build(factory)
    end

    def sandboxize(factory, object, attribute_name)
      if sandbox?
        build_fake(factory).send(attribute_name)
      else
        object.send(attribute_name)
      end
    end
end
