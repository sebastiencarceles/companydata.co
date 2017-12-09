# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout "_base"
  
  protect_from_forgery with: :exception
end
