# frozen_string_literal: true

class Api::V1::TableTennisController < ApiController
  def ping
    render json: { response: "pong" }
  end
end
