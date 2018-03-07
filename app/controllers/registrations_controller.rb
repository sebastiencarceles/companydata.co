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
      page_path('getting_started')
      Tracking::Mixpanel&.track(current_user.id, "Visit getting started")
    end
end
