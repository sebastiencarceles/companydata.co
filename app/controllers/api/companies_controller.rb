# frozen_string_literal: true

class Api::CompaniesController < ApplicationController
  def show
    company = Company.find_by_id(params[:id])
    render(json: {}, status: :not_found) && (return) unless company
    render json: company
  end
end
