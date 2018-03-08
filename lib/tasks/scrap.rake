# frozen_string_literal: true

namespace :scrap do
  task linkedin: :environment do
    LinkedinScrapper.new(Figaro.env.LINKEDIN_USERNAME, Figaro.env.LINKEDIN_PASSWORD).execute
  end

  task lehub: :environment do
    LehubScrapper.new(Figaro.env.LINKEDIN_USERNAME, Figaro.env.LINKEDIN_PASSWORD).execute
  end
end
