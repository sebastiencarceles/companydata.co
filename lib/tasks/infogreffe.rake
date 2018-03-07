# frozen_string_literal: true

require "csv"

namespace :infogreffe do
  task financial_years: :environment do
    ARGV.each { |a| task a.to_sym do ; end }

    fail "No year given" if ARGV[1].blank?
    fail "No source given" if ARGV[2].blank?

    begin
      year = ARGV[1].to_i
    rescue
      fail "Invalid year, should be 'YYYY' (for example: 2015)"
    end
    source = ARGV[2]

    Rails.logger.info "Load financial years from #{source}"

    CSV.foreach(source, col_sep: ";", headers: :first_row) do |row|
      reg_1 = row["Siren"]
      reg_2 = row["Nic"]
      next if reg_1.blank? || reg_2.blank?
      company = Company.where(registration_1: reg_1, registration_2: reg_2).first
      if company
        (1..3).each do |index|
          closing_date = row["Date de cloture exercice #{index}"]
          financial_year = company.financial_years.find_or_initialize_by(
            year: (year - (index - 1)),
            closing_date: closing_date
          )
          financial_year.currency = "€"
          financial_year.revenue = row["CA #{index}"]
          financial_year.income = row["Résultat #{index}"]
          financial_year.staff = row["Effectif #{index}"]
          financial_year.duration = row["Durée #{index}"]
          financial_year.closing_date = closing_date
          financial_year.save!
        end
      else
        Rails.logger.warn("No company found for #{reg_1} #{reg_2}")
      end
    end
  end

  task old_financial_years: :environment do
    source = "db/raw/infogreffe/chiffres-cles-2014.csv"

    Rails.logger.info "Load financial years from #{source}"

    CSV.foreach(source, col_sep: ";", headers: :first_row) do |row|
    puts row
      reg_1 = row["Siren"]
      next if reg_1.blank?

      company = Company.where(registration_1: reg_1, quality: "headquarter").first
      if company
        ["2014", "2013", "2012"].each do |year|
          financial_year = company.financial_years.find_or_initialize_by(year: year)
          financial_year.currency = "€"
          financial_year.revenue = row["CA #{year}"]
          financial_year.income = row["Resultat #{year}"]
          financial_year.staff = row["Effectif #{year}"]
          financial_year.save!
        end
      else
        Rails.logger.warn("No company found for #{reg_1}")
      end
    end
  end
end
