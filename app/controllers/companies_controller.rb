# frozen_string_literal: true

class CompaniesController < ApplicationController
  def show
    @query = params[:query]

    @company = Company.find_by_id(params[:id])
    @company ||= Company.find_by_slug(params[:id])
    @company ||= Company.find_by_name(params[:id])
    @company ||= Company.find_by_smooth_name(params[:id])

    raise ActiveRecord::RecordNotFound.new("#{params[:id]} not found") unless @company
  end

  def index
    unless params[:search].nil?
      @query = search_params[:query]
      @companies = Company.search(@query, fields: [:smooth_name], match: :word_start, page: params[:page], per_page: 20)
    end
  end

  private

    def search_params
      params.require(:search).permit(:query)
    end
end
