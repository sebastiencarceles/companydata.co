# frozen_string_literal: true

require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "open-uri"

class LinkedinScrapper
  def initialize(linkedin_id)
    @linkedin_id = linkedin_id
  end

  def execute
    session = build_session

    login(session)
    sleep 2
    open_company_page(session)
    sleep 3
    company_data = scrap(session)

    puts "poltergeist has found info on company: #{company_data}" # TODO remove

    Company.create!(company_data)
  end

  def build_session
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 30, phantomjs_options: ["--ignore-ssl-errors=yes", "--load-images=yes"])
    end
    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist
    Capybara::Session.new(:poltergeist)
  end

  def login(session)
    session.visit "https://www.linkedin.com/"
    session.fill_in "login-email", with: "sebastien.carceles@gmail.com"
    session.fill_in "login-password", with: "Lptitloup11"
    session.click_button "login-submit"
  end

  def open_company_page(session)
    session.visit linkedin_url
  end

  def scrap(session)
    {
      # TODO manage company logo
      name: session.find(".org-top-card-module__name")&.text,
      linkedin_url: linkedin_url,
      category: session.find(".company-industries")&.text,
      website: session.find(".org-about-us-company-module__website")&.text,
      headquarter_in: session.find(".org-about-company-module__headquarters")&.text,
      founded_in: session.find(".org-about-company-module__founded")&.text,
      type: session.find(".org-about-company-module__company-type")&.text,
      staff: session.find(".org-about-company-module__company-staff-count-range")&.text,
      specialities: session.find(".org-about-company-module__specialities")&.text,
      presentation: session.find(".org-about-us-organization-description__text")&.text,
    }
  end

  def linkedin_url
    "https://www.linkedin.com/company/#{@linkedin_id}"
  end
end
