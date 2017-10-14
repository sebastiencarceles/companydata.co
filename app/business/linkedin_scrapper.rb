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
    if open_company_page(linkedin_id)
      begin
        Company.create!(read_company_data(linkedin_id))
      rescue Capybara::Poltergeist::StatusFailError
        @logger.info("#{linkedin_id} - Status fail error, let's retry")
        scrap(linkedin_id)
      rescue Capybara::Poltergeist::TimeoutError
        @logger.info("#{linkedin_id} - Timeout error, let's retry")
        scrap(linkedin_id)
      rescue => exception
        @logger.error("#{linkedin_id} - #{exception} - #{exception.backtrace.join('\t')}")
        @session.save_screenshot "public/#{linkedin_id}.png", full: true
      else
        scrap(linkedin_id + 1)
      end
    else
      @logger.warn("#{linkedin_id} - This company does not exist, try the next one")
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
    sleep 5
    @logger.info("Logged in with username: #{@username}")
  end

  def open_company_page(linkedin_id)
    @logger.info("#{linkedin_id} - Opening company page")
    @session.visit linkedin_url(linkedin_id)
    sleep 10
    return @session.status_code != 404
  end

  def read_company_data(linkedin_id)
    {
      name: read_text(".org-top-card-module__name"),
      logo_url: @session.find(".org-top-card-module__logo")["src"],
      linkedin_url: linkedin_url(linkedin_id),
      category: read_text(".company-industries"),
      website: read_text(".org-about-us-company-module__website"),
      headquarter_in: read_text(".org-about-company-module__headquarters"),
      founded_in: read_text(".org-about-company-module__founded"),
      company_type: read_text(".org-about-company-module__company-type"),
      staff: read_text(".org-about-company-module__company-staff-count-range"),
      specialities: read_text(".org-about-company-module__specialities"),
      presentation: read_text(".org-about-us-organization-description__text"),
    }
  end

  def linkedin_url(linkedin_id)
    "https://www.linkedin.com/company/#{linkedin_id}/"
  end

  def read_text(css_class_name)
    begin
      @session.find(css_class_name).text
    rescue Capybara::ElementNotFound
      nil
    end
  end
end
