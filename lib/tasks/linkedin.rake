require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'open-uri'

namespace :linkedin do
  
  task company: :environment do |t|
    ARGV.each { |a| task a.to_sym do ; end }
    logger = Logger.new($stdout)
    
    logger.info 'poltergeist initialization'
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {
        js_errors: false,
        timeout: 60,
        # debug: true, 
        # phantomjs_logger: true, 
        # stdout: true, 
        phantomjs_options: ['--ignore-ssl-errors=yes','--load-images=yes']
      })
    end
    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist

    session = Capybara::Session.new(:poltergeist)
    logger.info 'poltergeist ready to haunt'
    
    # login
    session.visit 'https://www.linkedin.com/'
    session.fill_in 'login-email', with: 'sebastien.carceles@gmail.com'
    session.fill_in 'login-password', with: 'Lptitloup11'
    session.click_button 'login-submit'
    logger.info 'poltergeist is logged in!'
    sleep 2

    # search for company
    session.visit "https://www.linkedin.com/search/results/index/?keywords=#{ARGV[1]}"
    session.click_button 'Entreprises'
    sleep 3
    company_links = session.all('a').select { |a| a[:href].include?('https://www.linkedin.com/company/')}.map { |a| a[:href] }
    logger.info 'poltergeist is haunting companies'

    # open company link
    session.visit company_links[0]
    sleep 3
    company = {
      name: session.find(".org-top-card-module__name")&.text,
      linkedin_url: company_links[0],
      category: session.find(".company-industries")&.text,
      website: session.find('.org-about-us-company-module__website')&.text,
      headquarter_in: session.find('.org-about-company-module__headquarters')&.text,
      founded_in: session.find('.org-about-company-module__founded')&.text,
      type: session.find('.org-about-company-module__company-type')&.text,
      staff: session.find('.org-about-company-module__company-staff-count-range')&.text,
      specialities: session.find('.org-about-company-module__specialities')&.text,
      presentation: session.find(".org-about-us-organization-description__text")&.text,
      # TODO slug, linkedin_id
    }
    logger.info "poltergeist has found info on company #{ARGV[1]}: #{company}"
    session.save_and_open_screenshot
  end
end
