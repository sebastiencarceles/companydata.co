# frozen_string_literal: true

class CompaniesController < ApplicationController
  def scrap
    linkedin_id = params[:linkedin_id].to_i
    LinkedinScrapper.new(ENV["linkedin_username"], ENV["linkedin_password"], linkedin_id, batch: false).execute
    redirect_to "/#{linkedin_id}.png"
  end
end
