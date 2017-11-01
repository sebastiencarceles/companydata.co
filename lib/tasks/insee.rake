# frozen_string_literal: true

require "smarter_csv"

namespace :insee do
  task companies: :environment do
    filename = "db/raw/entreprises-immatriculees-2017.csv"
    options = {
      col_sep: ";",
      key_mapping: {
        "dénomination": :name,
        "siren": :registration_1,
        "nic": :registration_2,
        "forme_juridique": :company_type,
        "code_ape": :activity_code,
        "secteur_d'activité": :category,
        "adresse": :address_line_1,
        "code_postal": :zipcode,
        "ville": :city,
        "num._dept.": :department_code,
        "département": :department,
        "région": :region,
        "date_immatriculation": :founded_at,
        "geolocalisation": :geolocation,
        "fiche_identite": :source_url
      },
      remove_unmapped_keys: true,
      value_converters: {
        founded_at: DateConverter,
        registration_2: NicConverter
      }
    }
    SmarterCSV.process(filename, options) do |array|
      attributes = array.first
      puts attributes[:name]
      company = Company.find_by_name(attributes[:name])
      if company
        company.update!(attributes.merge(country: "France"))
      else
        Company.create!(attributes.merge(country: "France"))
      end
    end
  end

  class DateConverter
    def self.convert(value)
      Date.strptime(value, "%Y-%m-%d")
    end
  end

  class NicConverter
    def self.convert(value)
      value.to_s.rjust(5, "0")
    end
  end
end
