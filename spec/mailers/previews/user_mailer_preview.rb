# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def init_subscription
    UserMailer.with(user: User.first).init_subscription
  end
end
