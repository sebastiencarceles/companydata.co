# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout "_base"

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  def default_url_options
    { locale: I18n.locale }
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_of_service])
    end

  private

    def set_locale
      locale = params[:locale] || session[:locale] || I18n.default_locale
      I18n.locale = locale
      session[:locale] = locale
    end
end
