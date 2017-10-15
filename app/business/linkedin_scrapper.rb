# frozen_string_literal: true

require "csv"
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



    CSV.open("db/seed/companies.csv", "a", headers: true) do |csv|
      csv << [
        "linkedin_id",
        "name",
        "logo_url",
        "linkedin_url",
        "category",
        "website",
        "headquarter_in",
        "founded_in",
        "company_type",
        "staff",
        "specialities",
        "presentation"
      ]
      scrap(csv, 1000)
    end
  end

  def scrap(csv, linkedin_id)
    open_company_page(linkedin_id)
    begin
      csv << read_company_data(linkedin_id).values
    # rescue Net::Timeout
    #   puts "#{linkedin_id} - Status fail error, let's retry"
    #   scrap(csv, linkedin_id)
    rescue => exception
      puts exception
      puts exception.backtrace
      @session.save_screenshot "#{Rails.root.join('public').to_s}/#{linkedin_id}.png", full: true
    else
      scrap(csv, linkedin_id + 1)
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
    @session.visit "https://www.linkedin.com/"
    @session.fill_in "login-email", with: @username
    @session.fill_in "login-password", with: @password
    @session.click_button "login-submit"
    puts "Logged in with username: #{@username}"
  end

  def open_company_page(linkedin_id)
    @session.visit linkedin_url(linkedin_id)
    puts "#{linkedin_id} - Opening company page"
  end

  def read_company_data(linkedin_id)
    @session.find(".org-about-company-module__show-details-button").click
    {
      linkedin_id: linkedin_id,
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
    puts "read text for #{css_class_name}"
    begin
      @session.find(css_class_name).text
    rescue Capybara::ElementNotFound
      nil
    end
  end
end
