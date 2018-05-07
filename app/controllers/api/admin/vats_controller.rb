# frozen_string_literal: true

class Api::Admin::VatsController < Api::Admin::ApiController
  def to_check
    vat = Vat.where(status: "waiting_for_validation").first
    render(json: {}, status: :no_content) && (return) unless vat
    render(json: vat) && (return) if vat.update(status: "in_progress")
    render json: vat.errors.details, status: :bad_request
  end

  def update
    vat = Vat.find_by_id(params[:id])
    render(json: {}, status: :not_found) && (return) unless vat
    render(json: { error: "missing status" }, status: :bad_request) && return if params[:status].blank?
    render(json: vat) && (return) if vat.update(status: params[:status])
    render json: vat.errors.details, status: :bad_request
  end
end
