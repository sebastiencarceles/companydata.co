# frozen_string_literal: true

require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "open-uri"

class LinkedinScrapper
  def initialize(username, password, from_linkedin_id)
    @from_linkedin_id = from_linkedin_id
    @username = username
    @password = password
    @session = build_session
    @logger = Logger.new($stdout)
  end

  def execute
    login
    scrap(@from_linkedin_id)
  end

  def scrap(linkedin_id)
    @session.visit linkedin_url(linkedin_id)
    sleep 10
    begin
      company_data = read_company_data(linkedin_id)
      @logger.info(company_data)
      Company.create!(company_data)
    rescue => exception
      if [Capybara::Poltergeist::StatusFailError, Capybara::Poltergeist::TimeoutError].include?(exception.class)
        @logger.info("#{linkedin_id} - Timeout, let's retry")
        scrap(linkedin_id)
      elsif @session.status_code == 404
        @logger.warn("#{linkedin_id} - This company does not exist, try the next one")
        scrap(linkedin_id + 1)
      else
        @logger.error("#{linkedin_id} - #{exception.class}: #{exception.message}\n#{exception.backtrace.join('\n')}")
        @session.save_and_open_screenshot
      end
    else
      scrap(linkedin_id + 1)
    end
  end

  def build_session
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 60, phantomjs_options: ["--ignore-ssl-errors=yes", "--load-images=yes"])
    end
    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist
    Capybara::Session.new(:poltergeist)
  end

  def login
    @session.visit "https://www.linkedin.com/"
    @session.fill_in "login-email", with: @username
    @session.fill_in "login-password", with: @password
    @session.click_button "login-submit"
    sleep 2
    @logger.info("Logged in with username: #{@username}")
  end

  def read_company_data(linkedin_id)
    {
      name: @session.find(".org-top-card-module__name")&.text,
      logo_url: @session.find(".org-top-card-module__logo")["src"],
      linkedin_url: linkedin_url(linkedin_id),
      category: @session.find(".company-industries")&.text,
      website: @session.find(".org-about-us-company-module__website")&.text,
      headquarter_in: @session.find(".org-about-company-module__headquarters")&.text,
      founded_in: @session.find(".org-about-company-module__founded")&.text,
      company_type: @session.find(".org-about-company-module__company-type")&.text,
      staff: @session.find(".org-about-company-module__company-staff-count-range")&.text,
      specialities: @session.find(".org-about-company-module__specialities")&.text,
      presentation: @session.find(".org-about-us-organization-description__text")&.text,
    }
  end

  def linkedin_url(linkedin_id)
    "https://www.linkedin.com/company/#{linkedin_id}/"
  end
end
