# frozen_string_literal: true

class Api::TableTennisController < ApiController
  def ping
    render json: { response: "pong" }
  end
end
