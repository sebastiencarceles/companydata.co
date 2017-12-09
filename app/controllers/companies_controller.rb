class CompaniesController < ApplicationController
  def index
    query = params[:q]
    @companies = Company.fuzzy_search(name: query)
  end

  def show
  end
end
