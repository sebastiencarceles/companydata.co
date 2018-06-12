# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def init_subscription
    UserMailer.with(user: User.first).init_subscription
  end

  def no_subscription
    UserMailer.with(user: User.last).no_subscription
  end
end
