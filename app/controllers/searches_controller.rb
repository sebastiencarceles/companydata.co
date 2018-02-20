# frozen_string_literal: true

class SearchesController < ApplicationController
  def new
    @search = Search.new(user: current_user)
  end

  def create
    Search.create(search_params).save
    @companies = Company.search(search_params[:query], fields: [:name], page: params[:page], per_page: 20)
    @search = Search.new(search_params)
  end

  def index
    redirect_to new_search_path
  end

  private

    def search_params
      params.require(:search).permit(:query, :user)
    end
end
