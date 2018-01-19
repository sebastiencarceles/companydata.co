# frozen_string_literal: true

class CompaniesController < ApplicationController
  def show
    @company = Company.find_by_id(params[:id])
    @company ||= Company.find_by_slug(params[:id])
    @company ||= Company.find_by_name(params[:id])
    raise ActiveRecord::RecordNotFound.new("#{params[:id]} not found") unless @company
  end
end
