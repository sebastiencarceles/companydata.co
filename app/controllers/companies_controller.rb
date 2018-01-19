# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :find_company, only: :show

  def search
    query = params[:q]
    @companies = Company.search(query, fields: [:name], limit: 50)
  end

  def show
  end

  private

    def find_company
      @company = Company.find_by_id(params[:id])
      @company ||= Company.find_by_slug(params[:id])
      @company ||= Company.find_by_name(params[:id])
      raise ActiveRecord::RecordNotFound.new("#{params[:id]} not found") unless @company
    end
end
