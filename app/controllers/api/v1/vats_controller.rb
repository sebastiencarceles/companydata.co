# frozen_string_literal: true

class Api::V1::VatsController < ApiController
  def show
    value = params[:value]
    vat = Vat.find_by_value(value)
    render(json: {}, status: :not_found) && (return) unless vat

    vat.validate!

    render json: vat, sandbox: sandbox?
  end
end
