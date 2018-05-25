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
      if company.registration_1.blank?
        Rails.logger.warn "No registration number for company #{company.id}"
        next
      end
      other_companies = Company.where.not(id: company.id).where(registration_1: company.registration_1)
      quality = other_companies.empty? ? "headquarter" : "branch"
      Rails.logger.info "Set quality for company #{company.id}: #{quality}"
      company.update_columns(quality: quality)
    end
    Rails.logger.info "Done"
  end

  task fix_branches: :environment do
    Rails.logger.info "Fix consistency over branches"
    Company.branchs.find_each do |company|
      if company.branches.empty?
        Rails.logger.warn "Fix company #{company.id} which is not a branch but a headquarter"
        company.update(quality: "headquarter")
      end
    end
    Rails.logger.info "Done"
  end

  task country_codes: :environment do
    Rails.logger.info "Populate country codes"
    scope = Company.where(country: "France", country_code: nil)
    count = scope.count
    counter = 1
    scope.find_each do |company|
      Rails.logger.info "#{counter} / #{count}"
      company.update_columns(country_code: "FR")
      counter += 1
    end
    Rails.logger.info "Done"
  end

  task fix_geolocalized_at: :environment do
    Rails.logger.info "Fix geolocalized at: set it to created_at for companies already geocoded"
    Company.where(geolocalized_at: nil).find_each do |company|
      Rails.logger.info "Fix company #{company.id}"
      company.update_columns(geolocalized_at: company.created_at)
    end
    Rails.logger.info "Done"
  end
end
