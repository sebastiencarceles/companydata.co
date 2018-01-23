# frozen_string_literal: true

require "csv"

namespace :infogreffe do
  task financial_years: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    year = ARGV[1]
    source = ARGV[2]

    fail "No year given" if year.blank?
    fail "No source given" if source.blank?

    Rails.logger.info "Load financial years from #{source}"

    CSV.foreach(source, col_sep: ";", headers: :first_row) do |row|
      reg_1 = row["Siren"]
      reg_2 = row["Nic"]
      company = Company.where(registration_1: reg_1, registration_2: reg_2).first
      if company
        (1..3).each do |index|
        end
      else
        Rails.logger.warn("No company found for #{reg_1} #{reg_2}")
      end
    end
  end
end
