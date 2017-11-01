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
    # linkedin_id = (Company.where.not(linkedin_id: nil).order(:linkedin_id).last.linkedin_id + 1) rescue 1000
    linkedin_id = 2612
    scrap(linkedin_id)
  end

  def scrap(linkedin_id)
    begin
      open_company_page(linkedin_id)
      company_data = read_company_data(linkedin_id)
      pp company_data
      Company.create(company_data)
    rescue Net::ReadTimeout
      puts "#{linkedin_id} - Timeout, let's retry"
      scrap(linkedin_id)
    rescue => exception
      puts exception
      puts exception.backtrace
      @session.save_screenshot "#{Rails.root.join('public').to_s}/#{linkedin_id}.png", full: true
    else
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
    begin
      @session.find(".org-about-company-module__show-details-button").click
    rescue
      nil
    end
  end

  def read_company_data(linkedin_id)
    data = { linkedin_id: linkedin_id, source_url: linkedin_url(linkedin_id) }
    add!(data, :name, read_text(".org-top-card-module__name"))
    add!(data, :logo_url, read_image_source(".org-top-card-module__logo"))
    add!(data, :category, read_text(".company-industries"))
    add!(data, :website, read_text(".org-about-us-company-module__website"))
    add!(data, :headquarter_in, read_text(".org-about-company-module__headquarters"))
    add!(data, :founded_in, read_text(".org-about-company-module__founded"))
    add!(data, :company_type, read_text(".org-about-company-module__company-type"))
    add!(data, :staff, read_text(".org-about-company-module__company-staff-count-range"))
    add!(data, :specialities, read_text(".org-about-company-module__specialities"))
    add!(data, :presentation, read_text(".org-about-us-organization-description__text"))
    # add!(data, :name, read_text(".name"))
    # add!(data, :logo_url, read_image_source(".image"))
    # add!(data, :category, read_text(".industry"))
    # add!(data, :website, read_text(".website"))
    # add!(data, :headquarter_in, read_text("locality"))
    # add!(data, :address_line_1, read_text("street-address"))
    # add!(data, :city, read_text("locality"))
    # add!(data, :zipcode, read_text("postal-code"))
    # add!(data, :region, read_text("region"))
    # add!(data, :country, read_text("country-name"))
    # add!(data, :founded_in, read_text(".founded"))
    # add!(data, :company_type, read_text(".type"))
    # add!(data, :staff, read_text(".company-size"))
    # add!(data, :specialities, read_text(".specialties"))
    # add!(data, :presentation, read_text(".basic-info-description"))
    data
  end

  def add!(hash, key, value)
    return unless value
    hash[key] = value
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

  def read_image_source(css_class_name)
    begin
      @session.find(css_class_name)["src"]
    rescue
      nil
    end
  end
end
