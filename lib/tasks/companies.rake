# frozen_string_literal: true

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
      first_one = duplicates.shift
      Rails.logger.info "Destroy #{duplicates.count} entries"
      duplicates.each { |duplicate| duplicate.destroy! }
    end
  end

  task reindex: :environment do
    Rails.logger.info "Reindex companies"
    Company.reindex
  end

  task reslug: :environment do
    Rails.logger.info "Reslug companies"
    Company.where(slug: nil).find_each do |company|
      counter = 1
      slug = company.name.parameterize
      while Company.exists?(slug: slug) do
        slug = company.name.parameterize.strip + "-" + counter.to_s
        counter += 1
      end
      company.update_columns(slug: slug)
      Rails.logger.info "Slugged company: #{slug}"
    end
  end

  task refoundedin: :environment do
    Rails.logger.info "Recompute founded_in"
    Company.where(founded_in: nil).where.not(founded_at: nil).find_each do |company|
      company.update_columns(founded_in: company.founded_at.year)
      Rails.logger.info "Company #{company.id} founded in #{company.founded_at.year}"
    end
  end
end
