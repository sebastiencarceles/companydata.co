# frozen_string_literal: true

class Proabono
  include HTTParty
  base_uri Figaro.env.PROABONO_ENDPOINT

  def initialize(user)
    @user = user
  end

  ## Customer part

  def sign
    post("/Customer", ReferenceCustomer: @user.id, Email: @user.email)
  end

  def customer_portal
    sign[:Links].select { |link| link[:rel] == "hosted-home" }.first[:href]
  end

  ## Subscription

  def subscribe(offer = "free_trial")
    post("/Subscription", ReferenceCustomer: @user.id, ReferenceOffer: offer)
  end
  
  def subscription
    get("/Subscription", ReferenceCustomer: @user.id)
  end
  
  def subscription_name
    subscription&.dig(:TitleLocalized)
  end

  ## Usage

  def increment
    increment_by(1)
  end

  def increment_by(to_add)
    body = { ReferenceCustomer: @user.id, ReferenceFeature: "api_call", Increment: to_add, DateStamp: DateTime.now }
    self.class.post("/Usage", body: body, basic_auth: auth, headers: headers)
  end

  private

    def get(path, query)
      self.class.get(path, query: query, basic_auth: auth, headers: headers).parsed_response&.with_indifferent_access
    end

    def post(path, body)
      self.class.post(path, body: body, basic_auth: auth, headers: headers).parsed_response&.with_indifferent_access
    end

    def auth
      @auth ||= { username: Figaro.env.PROABONO_USERNAME, password: Figaro.env.PROABONO_PASSWORD }
    end

    def headers
      { Accept: "application/json" }
    end
end
