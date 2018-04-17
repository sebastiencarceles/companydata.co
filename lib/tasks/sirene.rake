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
      batch << Company.new(base_attributes_from(row))

      if batch.count >= 10000
        Company.import!(batch)
        puts "Total companies in database: #{Company.count}"
        batch.clear
      end
    end
    Company.import!(batch)
    puts "Total companies in database: #{Company.count}"
  end

  task geolocations: :environment do
    Rails.logger.info "Update companies geolocations"

    Dir.glob("db/raw/sirene/geocoded/*.csv").sort.each do |source|
      Rails.logger.info "Read from #{source}"

      CSV.foreach(source, col_sep: ",", encoding: "ISO-8859-1", headers: :first_row) do |row|
        company = Company.where(registration_1: row["SIREN"], registration_2: row["NIC"]).first
        unless company
          Rails.logger.info "Create missing company #{row["SIREN"]} #{row["NIC"]}"
          company = Company.create!(base_attributes_from(row))
        end

        lat = row["latitude"].to_f
        lng = row["longitude"].to_f
        score = row["geo_score"].to_f
        next if score == 0 || (company.lat.present? && company.lng.present?) || (lat == 0 || lng == 0)

        Rails.logger.info "Update geolocation of company #{company.id}: #{lat}, #{lng}"
        company.update_columns(lat: lat, lng: lng)
      end

      File.delete(source)
    end
  end

  task daily_update: :environment do
    update_from_daily(Date.today)
  end

  task stock_update: :environment do
    update_from("db/raw/sirene/sirc-17804_9075_14209_201802_L_M_20180301_031325537.csv")
  end

  task update_from_dailies: :environment do
    ARGV.each { |a| task a.to_sym do ; end }

    start_date = Date.parse(ARGV[1]) rescue nil
    end_date = Date.parse(ARGV[2]) rescue nil
    fail "No start date" if start_date.blank?
    fail "No end date" if end_date.blank?

    (start_date..end_date).each { |date| update_from_daily(date) }
  end

  private

    def update_from_daily(date)
      filename = "sirene_#{date.year}#{(date.yday - 4).to_s.rjust(3, "0")}_E_Q.zip"
      url = "http://files.data.gouv.fr/sirene/#{filename}"
      Rails.logger.info "Company daily update from #{url}"
      begin
        IO.copy_stream(open(url), filename)
      rescue OpenURI::HTTPError => error
        Rails.logger.warn "Unavailable source #{filename}"
        return if error.io.status.first == "404"
        fail error
      end

      Zip::File.open(filename) do |zip_file|
        zip_file.each do |entry|
          unziped_filename = entry.name
          entry.extract(unziped_filename)
          update_from(unziped_filename)
          File.delete(unziped_filename)
        end
      end
      File.delete(filename)
    end

    def update_from(source)
      Rails.logger.info "Update companies from #{source}"
      CSV.foreach(source, col_sep: ";", encoding: "ISO-8859-1", headers: :first_row) do |row|
        company = Company.where(registration_1: row["SIREN"], registration_2: row["NIC"]).first

        if closed?(row)
          if company
            Rails.logger.info "Company #{company.registration_1} #{company.registration_2} is closed, destroy it"
            company.destroy!
          end
          next
        end

        attributes = base_attributes_from(row)
        if company
          Rails.logger.info "Update company #{company.id}"
          company.update!(attributes)
        else
          Rails.logger.info "Create missing company #{row["SIREN"]} #{row["NIC"]}"
          Company.create!(attributes)
        end
      end
    end

    def base_attributes_from(row)
      if row["L7_NORMALISEE"].present? && row["L7_NORMALISEE"] != "FRANCE"
        Airbrake.notify("New country to manage: #{row["L7_NORMALISEE"]}")
      end

      {
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
        country_code: "FR",
        source_url: "https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret",
        civility: civility(row["CIVILITE"]),
        first_name: row["PRENOM"],
        last_name: row["NOM"],
        email: row["ADR_MAIL"],
        phone: row["TEL"]
      }
    end

    def closed?(row)
      row["VMAJ"] == "E"
    end

    def civility(value)
      case value
      when 1, "1"
        "Monsieur"
      when 2, "2"
        "Madame"
      else
        nil
      end
    end
end
