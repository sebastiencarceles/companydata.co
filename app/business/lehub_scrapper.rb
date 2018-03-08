# frozen_string_literal: true

require "capybara"
require "capybara/dsl"
require "open-uri"

class LehubScrapper
  def initialize(username, password)
    @username = username
    @password = password
    build_session
    @session = Capybara.current_session
  end

  def execute
    login
    scrap(1)
  end

  def scrap(startup_id)
    begin
      open_company_page(startup_id)
      company_data = read_company_data(startup_id)
      update_or_create(company_data) if company_data.any?
    rescue Net::ReadTimeout
      puts "#{startup_id} - Timeout, let's retry"
      scrap(startup_id)
    rescue => exception
      puts exception
      puts exception.backtrace
      @session.save_screenshot "#{Rails.root.join('public').to_s}/#{startup_id}.png", full: true
    else
      scrap(startup_id + 1)
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
    @session.visit "https://lehub.bpifrance.fr/auth/linkedin"
    @session.fill_in "session_key-login", with: @username
    @session.fill_in "session_password-login", with: @password
    @session.click_button "S’identifier"
    sleep 5
    @session.click_link "Continuer"
  end

  def open_company_page(startup_id)
    puts "Open company page ##{startup_id}"
    @session.visit "https://lehub.bpifrance.fr/startups/#{startup_id}"
  end

  def read_company_data(startup_id)
    @session.click_button "Afficher le contenu" rescue nil

    data = Hash.new
    add!(data, :siren, read_text(".StartupIdentityStyle__Siren-lu8hfj-1"))
    add!(data, :name, read_text(".StartupPresentationStyle__Name-s1hrglx-0"))
    add!(data, :presentation, read_text(".StartupPresentationStyle__Description-s1hrglx-1"))
    add!(data, :address, read_text(".StartupIdentityStyle__Content-lu8hfj-5"))
    add!(data, :creation, read_text("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Right-zi2cex-3.dTyRbE > div:nth-child(1) > div > div.StartupPresentationStyle__Informations-s1hrglx-2.fzRfCc > div:nth-child(1) > p"))
    add!(data, :staff, read_text("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Right-zi2cex-3.dTyRbE > div:nth-child(1) > div > div.StartupPresentationStyle__Informations-s1hrglx-2.fzRfCc > div:nth-child(3) > p"))
    add!(data, :website, read_text("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Left-zi2cex-2.gBoqlm > div.StartupIdentityStyle__Root-lu8hfj-0.viDol > div:nth-child(2) > div:nth-child(2) > div.StartupIdentityStyle__Content-lu8hfj-5.glDmCk > a"))
    add!(data, :email, read_text("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Left-zi2cex-2.gBoqlm > div.StartupIdentityStyle__Root-lu8hfj-0.viDol > div:nth-child(4) > div:nth-child(1) > div > a"))
    add!(data, :phone, read_text("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Left-zi2cex-2.gBoqlm > div.StartupIdentityStyle__Root-lu8hfj-0.viDol > div:nth-child(4) > div:nth-child(2) > div > span"))
    add!(data, :logo, read_style("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Left-zi2cex-2.gBoqlm > div.StartupLogoStyle__Root-s3wlh96-0.dOrwxu > div > div > div"))
    add!(data, :facebook, read_link_href("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Left-zi2cex-2.gBoqlm > div.StartupIdentityStyle__Root-lu8hfj-0.viDol > div:nth-child(2) > div:nth-child(3) > div > div > a.lu8hfj-8-StartupIdentityStyle__icon-exMlOa.dKfZRw"))
    add!(data, :twitter, read_link_href("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Left-zi2cex-2.gBoqlm > div.StartupIdentityStyle__Root-lu8hfj-0.viDol > div:nth-child(2) > div:nth-child(3) > div > div > a.lu8hfj-8-StartupIdentityStyle__icon-exMlOa.bqQbuO"))
    add!(data, :linkedin, read_link_href("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Left-zi2cex-2.gBoqlm > div.StartupIdentityStyle__Root-lu8hfj-0.viDol > div:nth-child(2) > div:nth-child(3) > div > div > a.lu8hfj-8-StartupIdentityStyle__icon-exMlOa.heiRGG"))
    add!(data, :crunchbase, read_link_href("#root > div > div.Layout__Container-s1sdl2xy-1.kmgrZo > div > div.StartupStyle__Main-zi2cex-0.bNQMXs > div.StartupStyle__Left-zi2cex-2.gBoqlm > div.StartupIdentityStyle__Root-lu8hfj-0.viDol > div:nth-child(2) > div:nth-child(3) > div > div > a.lu8hfj-8-StartupIdentityStyle__icon-exMlOa.gSNsKR"))
    data
  end

  def update_or_create(company_data)
    pp company_data
  end

  def add!(hash, key, value)
    return unless value
    hash[key] = value
  end

  def read_text(selector)
    begin
      @session.find(selector).text
    rescue Capybara::ElementNotFound
      nil
    end
  end

  def read_style(selector)
    begin
      @session.find(selector)["style"]
    rescue
      nil
    end
  end

  def read_image_source(selector)
    begin
      @session.find(selector)["src"]
    rescue
      nil
    end
  end

  def read_link_href(selector)
    begin 
      @session.find(selector)["href"]
    rescue
      nil
    end
  end
end