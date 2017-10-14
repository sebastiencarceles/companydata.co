# frozen_string_literal: true

namespace :linkedin do
  task companies: :environment do
    logger = Logger.new($stdout)
    linkedin_id = Company.order(:linkedin_id).last.try(:linkedin_id)
    linkedin_id ||= 1
    scrap(logger, linkedin_id)
  end

  def scrap(logger, linkedin_id)
    scrapper = LinkedinScrapper.new(linkedin_id)
    begin
      logger.info("Scrap company with LinkedIn ID #{linkedin_id}")
      scrapper.execute
    rescue => exception
      logger.warn("#{exception.class}: #{exception.message}")
      if [Capybara::Poltergeist::StatusFailError, Capybara::Poltergeist::TimeoutError].include?(exception.class)
        logger.info("Timeout, let's retry")
        scrap(logger, linkedin_id)
      elsif scrapper.session.status_code == 404
        logger.warn("This company does not exist, try the next one")
        scrap(logger, linkedin_id + 1)
      else
        logger.error("Please manage this new case")
        logger.info(exception.backtrace)
        scrapper.session.save_and_open_screenshot
      end
    else
      scrap(logger, linkedin_id + 1)
    end
  end
end
