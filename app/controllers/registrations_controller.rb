# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  protected

    def after_sign_up_path_for(resource) # override devise's
      after_sign_up_path
    end

    def after_inactive_sign_up_path_for(resource) # override devise's
      after_sign_up_path
    end

    def after_sign_up_path
      plan = params[:plan]
      if plan.present? && plan != "free"
        payment_path(plan: plan)
      else
        root_path # TODO redirect to API documentation
      end
    end

  # TODO redirect to API documentation
  # def after_confirmation_path_for(resource_name, resource)
  #   your_new_after_confirmation_path
  # end
end
