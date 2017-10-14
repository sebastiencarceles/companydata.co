# frozen_string_literal: true

namespace :linkedin do
  task companies: :environment do
    linkedin_id = Company.order(:linkedin_id).last.try(:linkedin_id)
    linkedin_id ||= 1115
    LinkedinScrapper.new("sebastien.carceles@gmail.com", "Lptitloup11", linkedin_id).execute
  end
end
