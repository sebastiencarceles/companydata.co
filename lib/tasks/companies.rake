# frozen_string_literal: true

require "open-uri"

namespace :companies do
  task dump: :environment do
    DataYaml.dump("db/raw", Company)
    DataYaml.dump("db/raw", FinancialYear)
  end

  task load: :environment do
    DataYaml.load("db/raw", Company)
    DataYaml.load("db/raw", FinancialYear)
  end

  task load_from_s3: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    subfolder = ARGV[1]
    fail "No subfolder given" if subfolder.nil?

    indir_url = "https://s3.eu-west-3.amazonaws.com/company-io/#{subfolder}"
    DataYaml.load_from_s3(indir_url, Company)
    DataYaml.load_from_s3(indir_url, FinancialYear)
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
      duplicates.shift # extract first one
      Rails.logger.info "Destroy #{duplicates.count} entries"
      duplicates.each { |duplicate| duplicate.destroy! }
    end
  end

  task reindex: :environment do
    Rails.logger.info "Reindex companies"
    Company.search_index.clean_indices
    Company.reindex
  end
end
