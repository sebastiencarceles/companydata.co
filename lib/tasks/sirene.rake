# frozen_string_literal: true

require "csv"

namespace :sirene do
  task companies: :environment do
    # source = "db/raw/sirene/sirc-17804_9075_14211_2017341_E_Q_20171208_022413655.csv"
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
        revenue: revenue(row["TCA"]),
        country: "France",
        source_url: "https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret"
      )

      if batch.count >= 10000
        Company.import!(batch)
        puts "Total companies in database: #{Company.count}"
        batch.clear
      end

      # t.string "website"
      # t.integer "linkedin_id"
      # t.text "specialities"
      # t.text "presentation"
      # t.string "logo_url"
      # t.string "geolocation"

    end
    Company.import!(batch)
    puts "Total companies in database: #{Company.count}"
  end

  private

    def revenue(tca)
      case tca
      when "9"
        "200 millions d'euros ou plus"
      when "8"
        "De 100 millions à moins de 200 millions d'euros"
      when "7"
        "De 50 millions à moins de 100 millions d'euros"
      when "6"
        "De 20 millions à moins de 50 millions d'euros"
      when "5"
        "De 10 millions à moins de 20 millions d'euros"
      when "4"
        "De 5 millions à moins de 10 millions d' euros"
      when "3"
        "De 2 millions à moins de 5 millions d'euros"
      when "2"
        "De 1 million à moins de 2 millions d'euros"
      when "1"
        "Moins de 0,5 million d'euros"
      else
        nil
      end
    end
end
