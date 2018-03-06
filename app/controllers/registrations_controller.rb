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
      # TODO redirect to getting started   
      root_path
    end
end
