# frozen_string_literal: true

class Proabono
  include HTTParty
  base_uri Figaro.env.PROABONO_ENDPOINT

  def initialize(user)
    @user = user
  end

  def update
    call("/Customer", ReferenceCustomer: @user.id, Email: @user.email)
  end

  def subscribe
    call("/Subscription", ReferenceCustomer: @user.id, ReferenceOffer: "free_trial")
  end

  def usage
    call("/Usage", ReferenceCustomer: @user.id, ReferenceFeature: "api_call", Increment: 1, DateStamp: DateTime.now)
  end

  private

    def call(path, body)
      self.class.post(path, body: body, basic_auth: auth,  headers: { 
        "Accept" => "application/json" 
      })
    end

    def auth
      @auth ||= { username: Figaro.env.PROABONO_USERNAME, password: Figaro.env.PROABONO_PASSWORD }
    end
end
