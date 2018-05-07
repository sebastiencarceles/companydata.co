# frozen_string_literal: true

class Api::Admin::VatsController < Api::Admin::ApiController
  def to_check
    vat = Vat.where(status: "waiting_for_validation").first
    render json: {}, status: :no_content and return unless vat
    
    vat.update!(status: "in_progress")
    render json: { value: vat.value }
  end
end