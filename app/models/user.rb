# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  def self.from_token_request(request)
    email = request.params["auth"] && request.params["auth"]["email"]
    self.find_by_email(email)
  end
end
