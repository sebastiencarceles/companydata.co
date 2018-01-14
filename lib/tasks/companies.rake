# frozen_string_literal: true

require "yaml"
require "net/http"

namespace :companies do
  FIRST_PAGE = 1
  PAGE_SIZE = 100000

  task dump: :environment do
    Rails.logger.info "Dump companies into local files"
    page = FIRST_PAGE
    while companies(page).any? do
      Rails.logger.info "Dump into #{filepath(page)}"
      File.open(filepath(page), "w") do |file|
        companies(page).each do |company|
          file.write(company.attributes.except("id", "created_at", "updated_at").to_yaml)
        end
      end
      page += 1
    end
  end

  task load: :environment do
    Rails.logger.info "Load companies from local files"
    page = FIRST_PAGE
    while File.exists?(filepath(page)) do
      Rails.logger.info "Load from #{filepath(page)}"
      YAML.load_stream(File.read(filepath(page))) do |company_data|
        Company.find_or_create_by(slug: company_data["slug"]) { |company| company.attributes = company_data }
      end
      page += 1
    end
    Company.reindex
  end

  task load_from_s3: :environment do
    Rails.logger.info "Load companies from AWS S3"
    ARGV.each { |a| task a.to_sym do ; end }
    subfolder = ARGV[1]
    return "No subfolder given" if subfolder.nil?

    page = FIRST_PAGE
    while remote_file_exists?(url(subfolder, page)) do
      Rails.logger.info "Load from #{url(subfolder, page)}"
      open(url(subfolder, page)) do |file|
        YAML.load_stream(file) do |company_data|
          Company.find_or_create_by(slug: company_data["slug"]) { |company| company.attributes = company_data }
        end
      end
      page += 1
    end
    Company.reindex
  end

  task dedupe: :environment do
    Rails.logger.info "Deduplicate companies"
    scope = Company.where.not(registration_1: nil).where.not(registration_2: nil).where(country: "France")
    scope.select(:registration_1, :registration_2).group(:registration_1, :registration_2).having("count(*) > 1").size.each do |k, v|
      raise "only one!" if v <= 1
      reg1 = k.first
      reg2 = k.last
      raise "reg1 is nil!" if reg1.nil?
      raise "reg2 is nil!" if reg2.nil?
      duplicates = Company.where(registration_1: reg1, registration_2: reg2).map { |company| company }
      first_one = duplicates.shift
      Rails.logger.info "Destroy #{duplicates.count} entries"
      duplicates.each { |duplicate| duplicate.destroy! }
    end
  end

  private

    def filepath(page)
      "db/raw/companies/companies-#{rjust(page)}.yml"
    end

    def companies(page)
      Company.order(:id).page(page).per(PAGE_SIZE)
    end

    def url(subfolder, page)
      "https://s3.eu-west-3.amazonaws.com/company-io/companies/#{subfolder}/companies-#{rjust(page)}.yml"
    end

    def remote_file_exists?(uri)
      url = URI.parse(uri)
      request = Net::HTTP.new(url.host, url.port)
      request.use_ssl = true
      request.request_head(url.path).code == "200"
    end

    def rjust(page)
      page.to_s.rjust(4, '0')
    end
end
