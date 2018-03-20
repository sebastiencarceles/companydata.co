# frozen_string_literal: true

class Api::V1::CompaniesController < ApiController
  def show
    identifier = params[:identifier]
    company = Company.find_by_id(identifier)
    company ||= Company.find_by_slug(identifier)
    company ||= Company.where(registration_1: identifier, quality: "headquarter").first
    company ||= Company.where(registration_1: identifier).first
    company ||= Vat.find_by_value(identifier).try(:company)
    render(json: {}, status: :not_found) && (return) unless company
    render json: company, serializer: Api::V1::FullCompanySerializer
  end

  def show_by_registration_numbers
    company = Company.where(registration_1: params[:identifier], registration_2: params[:registration_2]).first
    render(json: {}, status: :not_found) && (return) unless company
    render json: company, serializer: Api::V1::FullCompanySerializer
  end

  def index
    query = params[:q]
    render(json: [], status: :bad_request) && (return) unless query

    quality = params[:quality] || "headquarter"
    render(json: [], status: :bad_request) && (return) unless quality.in?(Company::QUALITIES + ["all"])

    where = quality == "all" ? {} : { quality: quality }
    scope = Company.search(query, fields: [:smooth_name], match: :word_start, where: where, page: page, per_page: per_page)
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
