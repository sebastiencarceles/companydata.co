# frozen_string_literal: true

namespace :linkedin do
  task companies: :environment do
    LinkedinScrapper.new(ENV["linkedin_username"], ENV["linkedin_password"]).execute
  end
end
