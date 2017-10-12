# frozen_string_literal: true

namespace :linkedin do
  task companies: :environment do
    logger = Logger.new($stdout)
    linkedin_id = Company.order(:linkedin_id).last.try(:linkedin_id)
    linkedin_id ||= 1
    scrap(logger, linkedin_id)
  end

  def scrap(logger, linkedin_id)
    begin
      logger.info("Scrap company with LinkedIn ID #{linkedin_id}")
      LinkedinScrapper.new(linkedin_id).execute
    rescue => exception
      logger.warn("#{exception.class}: #{exception.message}")
      if [
          Capybara::Poltergeist::StatusFailError,
          Capybara::Poltergeist::TimeoutError
        ].include?(exception.class)
        logger.info("Let's retry")
        scrap(logger, linkedin_id)
      else
        logger.error("Please manage this new case")
      end
    else
      scrap(logger, linkedin_id + 1)
    end
  end
end
