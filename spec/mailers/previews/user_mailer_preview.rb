# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def init_subscription
    UserMailer.with(user_id: User.first.id).init_subscription
  end

  def no_subscription
    UserMailer.with(user_id: User.first.id).no_subscription
  end
end
