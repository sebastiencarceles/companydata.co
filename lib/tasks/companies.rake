# frozen_string_literal: true

require "yaml"

namespace :companies do
  FIRST_PAGE = 1
  PAGE_SIZE = 25000

  task dump: :environment do
    page = FIRST_PAGE
    # TODO factorize
    while(Company.order(:id).page(page).per(PAGE_SIZE).any?) do
      puts "Dump page #{as_string(page)}"
      File.open("db/data/companies-#{as_string(page)}.yml", "w") do |file|
        Company.order(:id).page(page).per(PAGE_SIZE).each do |company|
          file.write(company.attributes.except("created_at", "updated_at").to_yaml)
        end
      end
      page += 1
    end
  end

  task load: :environment do
    page = FIRST_PAGE
    # TODO factorize
    while(File.exists?("db/data/companies-#{as_string(page)}.yml")) do
      puts "Load page #{as_string(page)}"
      YAML.load_stream(File.read("db/data/companies-#{as_string(page)}.yml")) do |company_data|
        Company.find_or_create_by(slug: company_data["slug"]) { |company| company.attributes = company_data.except("id") }
      end
      page += 1
    end
  end

  private

    def as_string(page)
      page.to_s.rjust(4, '0')
    end
end
