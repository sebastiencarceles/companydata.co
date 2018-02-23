# frozen_string_literal: true

class Api::V1::CompaniesController < ApiController
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
    scope = Company.search(query, fields: [:smooth_name], match: :word_start, page: page, per_page: per_page)
    response.headers["X-Pagination-Limit-Value"] = scope.limit_value
    response.headers["X-Pagination-Total-Pages"] = scope.total_pages
    response.headers["X-Pagination-Current-Page"] = scope.current_page
    response.headers["X-Pagination-Next-Page"] = scope.next_page
    response.headers["X-Pagination-Prev-Page"] = scope.prev_page
    response.headers["X-Pagination-First-Page"] = scope.first_page?
    response.headers["X-Pagination-Last-Page"] = scope.last_page?
    response.headers["X-Pagination-Out-Of-Range"] = scope.out_of_range?
    render json: scope
  end

  private

    def page
      params[:page].presence || 1
    end

    def per_page
      [params[:per_page].presence&.to_i || 10, 25].min
    end
end
