class User < ApplicationRecord
  has_secure_password

  # TODO validate user format

  validates_presence_of :firstname, :lastname, :email, :password_digest
  validates_uniqueness_of :email, case_sensitive: false

  def self.from_token_request(request)
    email = request.params['auth'] && request.params['auth']['email']
    self.find_by_email(email)
  end
end
