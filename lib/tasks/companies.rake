# frozen_string_literal: true

require "yaml"

namespace :companies do
  FIRST_PAGE = 1
  PAGE_SIZE = 25000

  task dump: :environment do
    page = FIRST_PAGE
    while companies(page).any? do
      puts "Dump into #{filepath(page)}"
      File.open(filepath(page), "w") do |file|
        companies(page).each do |company|
          file.write(company.attributes.except("id", "created_at", "updated_at").to_yaml)
        end
      end
      page += 1
    end
  end

  task load: :environment do
    page = FIRST_PAGE
    while File.exists?(filepath(page)) do
      puts "Load from #{filepath(page)}"
      YAML.load_stream(File.read(filepath(page))) do |company_data|
        Company.find_or_create_by(slug: company_data["slug"]) { |company| company.attributes = company_data }
      end
      page += 1
    end
  end

  task dedupe: :environment do
    scope = Company.where.not(registration_1: nil).where.not(registration_2: nil).where(country: "France")
    scope.select(:registration_1, :registration_2).group(:registration_1, :registration_2).having("count(*) > 1").size.each do |k, v|
      raise "only one!" if v <= 1
      reg1 = k.first
      reg2 = k.last
      raise "reg1 is nil!" if reg1.nil?
      raise "reg2 is nil!" if reg2.nil?
      duplicates = Company.where(registration_1: reg1, registration_2: reg2).map { |company| company }
      first_one = duplicates.shift
      puts "Destroy #{duplicates.count} entries"
      duplicates.each { |duplicate| duplicate.destroy! }
    end
  end

  private

    def filepath(page)
      "db/data/companies-#{page.to_s.rjust(4, '0')}.yml"
    end

    def companies(page)
      Company.order(:id).page(page).per(PAGE_SIZE)
    end
end
