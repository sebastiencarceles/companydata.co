# frozen_string_literal: true

require "smarter_csv"

namespace :insee do
  task companies: :environment do
    filename = "db/raw/entreprises-immatriculees-2017.csv"
    options = {
      chunk_size: 100,
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
        "fiche_identite": :source_link
      },
      remove_unmapped_keys: true
    }
    SmarterCSV.process(filename, options) do |chunk|
      # we're passing a block in, to process each resulting hash / row (block takes array of hashes)
      # when chunking is enabled, there are up to :chunk_size hashes in each chunk
      pp chunk   # insert up to 100 records at a time
    end
  end
end
