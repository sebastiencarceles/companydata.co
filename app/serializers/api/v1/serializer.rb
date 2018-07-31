# frozen_string_literal: true

class Api::V1::Serializer < ActiveModel::Serializer
  protected
    def sandbox?
      instance_options[:sandbox].present?
    end

    def sandboxize(factory, object, attribute_name)
      if sandbox?
        FactoryBot.build(factory).send(attribute_name)
      else
        object.send(attribute_name)
      end
    end
end
