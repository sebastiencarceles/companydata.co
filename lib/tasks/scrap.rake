# frozen_string_literal: true

namespace :scrap do
  task linkedin: :environment do
    LinkedinScrapper.new(Figaro.env.LINKEDIN_USERNAME, Figaro.env.LINKEDIN_PASSWORD).execute
  end

  task lehub: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    from_id = ARGV[1].to_i
    to_id = ARGV[2].to_i
    
    LehubScrapper.new(Figaro.env.LINKEDIN_USERNAME, Figaro.env.LINKEDIN_PASSWORD, from_id, to_id).execute
  end
end
