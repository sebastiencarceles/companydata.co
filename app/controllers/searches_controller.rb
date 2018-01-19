# frozen_string_literal: true

class SearchesController < ApplicationController
  def create
    Search.create(search_params).save
    @companies = Company.search(search_params[:query], fields: [:name], limit: 50)
    @search = Search.new(search_params)
  end

  private

    def search_params
      params.require(:search).permit(:query, :user)
    end
end
