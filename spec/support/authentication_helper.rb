# frozen_string_literal: true

module AuthenticationHelper
  def current_user
    @user ||= FactoryGirl.create :user
  end

  def authentication_header
    "todo"
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
