# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.1.4"
# Use postgre as the database for Active Record
gem "pg"
# Use Puma as the app server
gem "puma", "~> 3.7"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Scrapping
gem "capybara", "~> 2.15.1"
gem "selenium-webdriver"
gem "chromedriver-helper"
gem "poltergeist"

# Manage config var
gem "figaro"

# Import data from CSV
gem "smarter_csv"

# Authentication
gem "devise"

# Serialization
gem "active_model_serializers", "~> 0.10.0"

# Search
gem "elasticsearch", ">= 1.0.15"
gem "faraday_middleware-aws-signers-v4", ">= 0.1.9"
gem "searchkick"

# Pagination
gem "kaminari"

# Bulk import
gem "activerecord-import"

# Forms
gem "simple_form"

# Emails
gem "sendgrid-ruby"

# Bugs
gem "bugsnag"

# Translations
gem "i18n-tasks", "~> 0.9.20"

# Static pages
gem "high_voltage", "~> 3.0.0"

# Analytics
gem "mixpanel-ruby"

# Autocomplete
gem "twitter-typeahead-rails"
gem "handlebars_assets"

# Cross origin calls
gem "rack-cors", require: "rack/cors"

# SOAP client
gem "savon", "~> 2.0"

# Fixtures for HTTP responses while testing
gem "ephemeral_response"

# Uncompress zip files
gem "rubyzip", ">= 1.0.0"

# Icons
gem "font-awesome-rails"

# Monitoring
gem "newrelic_rpm"

# Async jobs
gem "sidekiq"

# Internationalization
gem "rails-i18n", "~> 5.1"

# HTTP Client
gem "httparty"

# Fake data for testing and sandbox mode
gem "faker", git: "git://github.com/stympy/faker.git", branch: "master"
gem "factory_bot_rails", "~> 4.0"

group :test do
  # Spec jobs
  gem "rspec-sidekiq"
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]

  gem "letter_opener"

  # Test tools
  gem "rspec-rails", "~> 3.6"
  gem "shoulda-matchers", "~> 3.1"
  gem "shoulda-callback-matchers", "~> 1.1", ">= 1.1.3"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "spring-commands-rspec"

  # to check code style
  gem "rubocop", require: false
  gem "rubocop-rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Themes
source "https://gems.rapidrailsthemes.com/gems" do
  gem "rrt", "~> 1.0.17"
end
gem "jquery-rails"
