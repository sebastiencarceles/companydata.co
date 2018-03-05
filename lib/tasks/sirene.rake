# frozen_string_literal: true

# Sources: 
# - SIRENE: https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/
# - Geocoded SIRENE: http://212.47.238.202/geo_sirene/last/

require "csv"

namespace :sirene do
  task initial_import: :environment do
    source = "db/raw/sirene/sirc-17804_9075_14209_201711_L_M_20171201_044556778.csv"

    batch = []
    CSV.foreach(source, col_sep: ";", encoding: "ISO-8859-1", headers: :first_row) do |row|
      batch << Company.new(
        registration_1: row["SIREN"],
        registration_2: row["NIC"],
        name: row["NOMEN_LONG"],
        address_line_1: row["L1_NORMALISEE"],
        address_line_2: row["L2_NORMALISEE"],
        address_line_3: row["L3_NORMALISEE"],
        address_line_4: row["L4_NORMALISEE"],
        address_line_5: row["L5_NORMALISEE"],
        zipcode: row["CODPOS"],
        cedex: row["CEDEX"],
        region: row["LIBREG"],
        department_code: row["DEPET"],
        city: row["LIBCOM"],
        quality: (row["SIEGE"] == "1" ? "headquarter" : "branch"),
        activity_code: row["APET700"],
        category: row["LIBAPET"],
        legal_form: row["LIBNJ"],
        staff: row["LIBTEFEN"],
        founded_at: row["DCREN"].nil? ? nil : (Date.parse(row["DCREN"]) rescue nil),
        country: "France",
        source_url: "https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret"
      )

      if batch.count >= 10000
        Company.import!(batch)
        puts "Total companies in database: #{Company.count}"
        batch.clear
      end
    end
    Company.import!(batch)
    puts "Total companies in database: #{Company.count}"
  end

  task update_geolocations: :environment do
    Rails.logger.info "Update companies geolocations"

    Dir.glob("db/raw/sirene/geocoded/*.csv").sort.each do |source|
      Rails.logger.info "Read from #{source}"

      CSV.foreach(source, col_sep: ",", encoding: "ISO-8859-1", headers: :first_row) do |row|
        score = row["geo_score"].to_f
        next if score == 0

        company = Company.where(registration_1: row["SIREN"], registration_2: row["NIC"]).first
        fail "Unknown company #{row["SIREN"]} #{row["NIC"]}" unless company
        
        next if company.lat.present? && company.lng.present?

        lat = row["latitude"].to_f
        lng = row["longitude"].to_f

        if lat != 0 && lng != 0
          Rails.logger.info "Update geolocation of company #{company.id}: #{lat}, #{lng}"
          ompany.update_columns(lat: lat, lng: lng) 
        end
      end

      File.delete(source)
    end
  end
end
