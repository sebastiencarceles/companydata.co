# frozen_string_literal: true

class Proabono
  include HTTParty
  base_uri Figaro.env.PROABONO_ENDPOINT

  def initialize(user)
    @user = user
  end

  def update
    post("/Customer", ReferenceCustomer: @user.id, Email: @user.email)
  end

  def customer_portal
    update[:Links].select { |link| link[:rel] == "hosted-home" }.first[:href]
  end

  def usage
    post("/Usage", ReferenceCustomer: @user.id, ReferenceFeature: "api_call", Increment: 1, DateStamp: DateTime.now)
  end

  def subscribe
    post("/Subscription", ReferenceCustomer: @user.id, ReferenceOffer: "free_trial")
  end

  def subscription
    get("/Subscription", ReferenceCustomer: @user.id)
  end

  def subscription_name
    subscription&.dig(:TitleLocalized)
  end

  private

    def get(path, query)
      self.class.get(path, query: query, basic_auth: auth, headers: headers).parsed_response&.with_indifferent_access
    end

    def post(path, body)
      self.class.post(path, body: body, basic_auth: auth,  headers: headers).parsed_response&.with_indifferent_access
    end

    def auth
      @auth ||= { username: Figaro.env.PROABONO_USERNAME, password: Figaro.env.PROABONO_PASSWORD }
    end

    def headers
      { Accept: "application/json" }
    end
end
