# frozen_string_literal: true

class Api::CompaniesController < ApiController
  def show
    company = Company.find_by_id(params[:identifier])
    company ||= Company.find_by_slug(params[:identifier])
    company ||= Company.find_by_name(params[:identifier])
    company ||= Company.find_by_smooth_name(params[:identifier])

    render(json: {}, status: :not_found) && (return) unless company
    render json: company
  end

  def index
    query = params[:q]
    render(json: {}, status: :bad_request) && (return) unless query
    render json: Company.search(query, fields: [:name, :smooth_name], limit: 50)
  end
end
