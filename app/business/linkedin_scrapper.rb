# frozen_string_literal: true

require "capybara"
require "capybara/dsl"
require "open-uri"

class LinkedinScrapper
  def initialize(username, password)
    @username = username
    @password = password
    build_session
    @session = Capybara.current_session
  end

  def execute
    login
    linkedin_id = (Company.where.not(linkedin_id: nil).order(:linkedin_id).last.linkedin_id + 1) rescue 1000
    scrap(linkedin_id)
  end

  def scrap(linkedin_id)
    begin
      Company.create(read_company_data(linkedin_id)) if open_company_page(linkedin_id)
    rescue Net::ReadTimeout
      puts "#{linkedin_id} - Timeout, let's retry"
      scrap(linkedin_id)
    rescue => exception
      puts exception
      puts exception.backtrace
      @session.save_screenshot "#{Rails.root.join('public').to_s}/#{linkedin_id}.png", full: true
    else
      sleep(Random.rand(30))
      scrap(linkedin_id + 1)
    end
  end

  def build_session
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end
    Capybara.javascript_driver = :chrome
    Capybara.configure do |config|
      config.default_max_wait_time = 30
      config.default_driver = :selenium
    end
    Capybara.current_session.driver.browser.manage.window.resize_to(1_280, 1_024)
  end

  def login
    puts "Login with username: #{@username}"
    @session.visit "https://www.linkedin.com/"
    @session.fill_in "login-email", with: @username
    @session.fill_in "login-password", with: @password
    @session.click_button "login-submit"
  end

  def open_company_page(linkedin_id)
    puts "Open company page ##{linkedin_id}"
    @session.visit linkedin_url(linkedin_id)
    return shows_more? || has_description?
  end

  def read_company_data(linkedin_id)
    company_data = {
      linkedin_id: linkedin_id,
      name: read_text(".org-top-card-module__name"),
      logo_url: @session.find(".org-top-card-module__logo")["src"],
      source_url: linkedin_url(linkedin_id),
      category: read_text(".company-industries"),
      website: read_text(".org-about-us-company-module__website"),
      headquarter_in: read_text(".org-about-company-module__headquarters"),
      founded_in: read_text(".org-about-company-module__founded"),
      company_type: read_text(".org-about-company-module__company-type"),
      staff: read_text(".org-about-company-module__company-staff-count-range"),
      specialities: read_text(".org-about-company-module__specialities"),
      presentation: read_text(".org-about-us-organization-description__text"),
    }
    pp company_data
    company_data
  end

  def linkedin_url(linkedin_id)
    "https://www.linkedin.com/company/#{linkedin_id}/"
  end

  def shows_more?
    begin
      @session.find(".org-about-company-module__show-details-button").click
    rescue Capybara::ElementNotFound
      false
    else
      true
    end
  end

  def has_description?
    read_text(".org-about-us-organization-description__text").present?
  end

  def read_text(css_class_name)
    begin
      @session.find(css_class_name).text
    rescue Capybara::ElementNotFound
      nil
    end
  end
end
