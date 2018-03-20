# frozen_string_literal: true

require "open-uri"

namespace :companies do
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

  task fix_nil_quality: :environment do
    Rails.logger.info "Fix companies with no quality"
    Company.where(quality: nil).order(:id).each do |company|
      fail "No registration number for company #{company.id}" if company.registration_1.blank?
      other_companies = Company.where.not(id: company.id).where(registration_1: company.registration_1)
      quality = other_companies.empty? ? "headquarter" : "branch"
      Rails.logger.info "Set quality for company #{company.id}: #{quality}"
      company.update_columns(quality: quality)
    end
    Rails.logger.info "Done"
  end

  task fix_headquarters: :environment do
    Rails.logger.info "Check for consistency over headquarters"
    count = 0
    Company.headquarters.find_each do |company|
      other_headquarters = Company.where.not(id: company.id).where(quality: "headquarter", registration_1: company.registration_1)
      if other_headquarters.any?
        Rails.logger.warn "Fix companies with registration number #{company.registration_1}"
        companies = Company.where(quality: "headquarter", registration_1: company.registration_1).order(:founded_at).to_a
        companies.shift
        count += companies.map { |c| c.update_columns(quality: "branch") }.count
      end
    end
    Rails.logger.info "Done, #{count} companies fixed"
  end

  task check_branches: :environment do
    Rails.logger.info "Check for consistency over branches"
    Company.branches.find_each do |company|
      Rails.logger.warn "No headquarter for branch company #{company.id}" if company.headquarter.nil?
    end
    Rails.logger.info "Check completed successfully"
  end
end
