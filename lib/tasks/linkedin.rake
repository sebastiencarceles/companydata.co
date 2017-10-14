# frozen_string_literal: true

namespace :linkedin do
  task companies: :environment do
    linkedin_id = Company.order(:linkedin_id).last.try(:linkedin_id)
    linkedin_id ||= 1000
    LinkedinScrapper.new(ENV["linkedin_username"], ENV["linkedin_password"], linkedin_id).execute
  end
end
