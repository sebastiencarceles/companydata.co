class CompaniesController < ApplicationController
  def search
    query = params[:q]
    @companies = Company.fuzzy_search(name: query)
  end

  def show
  end
end
