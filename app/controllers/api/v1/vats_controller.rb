# frozen_string_literal: true

class Api::V1::VatsController < ApiController
  before_action :show_sandbox, if: :sandbox?

  def show
    value = params[:value]
    vat = Vat.find_by_value(value)
    render(json: {}, status: :not_found) && (return) unless vat

    vat.validate!

    render json: vat
  end

  private

    def show_sandbox
      render json: FactoryBot.build(:vat, value: params[:value])
    end
end
