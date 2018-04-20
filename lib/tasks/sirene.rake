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

  task countries: :environment do
    ARGV.each { |a| task a.to_sym do ; end }

    start_date = Date.parse(ARGV[1]) rescue nil
    end_date = Date.parse(ARGV[2]) rescue nil
    fail "No start date" if start_date.blank?
    fail "No end date" if end_date.blank?

    countries = []
    (start_date..end_date).each do |date|
      filename = "sirene_#{date.year}#{(date.yday - 4).to_s.rjust(3, "0")}_E_Q.zip"
      url = "http://files.data.gouv.fr/sirene/#{filename}"
      Rails.logger.info "Company daily update from #{url}"
      begin
        IO.copy_stream(open(url), filename)
      rescue OpenURI::HTTPError => error
        Rails.logger.warn "Unavailable source #{filename}"
        next if error.io.status.first == "404"
        fail error
      end

      Zip::File.open(filename) do |zip_file|
        zip_file.each do |entry|
          unziped_filename = entry.name
          entry.extract(unziped_filename)
          
          CSV.foreach(unziped_filename, col_sep: ";", encoding: "ISO-8859-1", headers: :first_row) do |row|
            countries << row["L7_NORMALISEE"] unless countries.include?(row["L7_NORMALISEE"])
          end

          File.delete(unziped_filename)
        end
      end
      File.delete(filename)
    end
    pp countries
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
      country, country_code = get_country(row)
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
        country: country,
        country_code: country_code,
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

    def get_country(row)
      return "France", "FR" if row["L7_NORMALISEE"].blank?

      case row["L7_NORMALISEE"]
      when "AFRIQUE DU SUD"
        ["South Africa", "ZA"]
      when "ALBANIE"
        ["Albania", "AL"]
      when "ALGERIE"
        ["Algeria", "DZ"]
      when "ALLEMAGNE"
        ["Germany", "DE"]
      when "ANDORRE"
        ["Andorra", "AD"]
      when "ARABIE SAOUDITE"
        ["Saudi Arabia", "SA"]
      when "ARMENIE"
        ["Armenia", "AM"]
      when "AUSTRALIE"
        ["Australia", "AU"]
      when "AUTRICHE"
        ["Austria", "AT"]
      when "AZERBAIDJAN"
        ["Azerbaijan", "AZ"]
      when "BAHAMAS"
        ["Bahamas", "BS"]
      when "BARBADE"
        ["Barbados", "BB"]
      when "BELGIQUE"
        ["Belgium", "BE"]
      when "BELIZE"
        ["Belize", "BZ"]
      when "BENIN"
        ["Benin", "BJ"]
      when "BIRMANIE"
        ["Myanmar", "MM"]
      when "BOTSWANA"
        ["Botswana", "BW"]
      when "BRESIL"
        ["Brazil", "BR"]
      when "BULGARIE"
        ["Bulgaria", "BG"]
      when "BURKINA"
        ["Burkina Faso", "BF"]
      when "CAMBODGE"
        ["Cambodia", "KH"]
      when "CAMEROUN"
        ["Cameroon", "CM"]
      when "CANADA"
        ["Canada", "CA"]
      when "CAP VERT"
        ["Cape Verde", "CV"]
      when "CHILI"
        ["Chile", "CL"]
      when "CHINE"
        ["China", "CN"]
      when "CHYPRE"
        ["Cyprus", "CY"]
      when "COLOMBIE"
        ["Colombia", "CO"]
      when "COMORES"
        ["Comoros", "KM"]
      when "CONGO"
        ["Congo", "CG"]
      when "COREE", "COREE DU SUD"
        ["Republic of Korea", "KR"]
      when "COSTA RICA"
        ["Costa Rica", "CR"]
      when "COTE D'IVOIRE"
        ["Côte d'Ivoire", "CI"]
      when "CROATIE"
        ["Croatia", "HR"]
      when "CUBA"
        ["Cuba", "CU"]
      when "DANEMARK"
        ["Denmark", "DK"]
      when "DJIBOUTI"
        ["Djibouti", "DJ"]
      when "EGYPTE"
        ["Egypt", "EG"]
      when "EMIRATS ARABES UNIS"
        ["United Arab Emirates", "AE"]
      when "ESPAGNE"
        ["Spain", "ES"]
      when "ESTONIE"
        ["Estonia", "EE"]
      when "ETATS-UNIS"
        ["United States", "US"]
      when "EX REPUBLIQUE YOUGOSLAVE DE MACEDOI", "EX REPUBLIQUE YOUGOSLAVE MACEDOINE"
        ["The Former Yugoslav Republic of Macedonia", "MK"]
      when "FINLANDE"
        ["Finland", "FI"]
      when "FRANCE"
        ["France", "FR"]
      when "GABON"
        ["Gabon", "GA"]
      when "GHANA"
        ["Ghana", "GH"]
      when "GIBRALTAR"
        ["Gibraltar", "GI"]
      when "GRECE"
        ["Greece", "GR"]
      when "GRENADE"
        ["Grenada", "GD"]
      when "GUADELOUPE"
        ["Guadeloupe", "GP"]
      when "GUATEMALA"
        ["Guatemala", "GT"]
      when "GUINEE"
        ["Guinea", "GN"]
      when "GUYANE FRANCAISE"
        ["Guyana", "GY"]
      when "HONGRIE"
        ["Hungary", "HU"]
      when "ILE DE LA REUNION"
        ["Réunion", "RE"]
      when "ILES BAHREIN"
        ["Bahrain", "BH"]
      when "ILES MARSHALL"
        ["Marshall Islands", "MH"]        
      when "ILES MAURICE"
        ["Mauritius", "MU"]
      when "INDE"
        ["India", "IN"]
      when "INDONESIE"
        ["Indonesia", "ID"]
      when "IRAN"
        ["Islamic Republic of Iran", "IR"]
      when "IRLANDE"
        ["Ireland", "IE"]
      when "ISLANDE"
        ["Iceland", "IS"]
      when "ISRAEL"
        ["Israel", "IL"]
      when "ITALIE"
        ["Italy", "IT"]
      when "JAMAIQUE"
        ["Jamaica", "JM"]
      when "JAPON"
        ["Japan", "JP"]
      when "JORDANIE"
        ["Jordan", "JO"]
      when "KAZAKHSTAN"
        ["Kazakhstan", "KZ"]
      when "KENYA"
        ["Kenya", "KE"]
      when "KOSOVO"
        ["Kosovo", "XK"]
      when "KOWEIT"
        ["Kuwait", "KW"]
      when "LETTONIE"
        ["Latvia", "LV"]
      when "LIBAN"
        ["Lebanon", "LB"]
      when "LIBYE"
        ["Libya", "LY"]
      when "LIECHTENSTEIN"
        ["Liechtenstein", "LI"]
      when "LITUANIE"
        ["Lithuania", "LT"]
      when "LUXEMBOURG"
        ["Luxembourg", "LU"]
      when "MADAGASCAR"
        ["Madagascar", "MG"]
      when "MALAISIE"
        ["Malaysia", "MY"]
      when "MALI"
        ["Mali", "ML"]
      when "MALTE"
        ["Malta", "MT"]
      when "MAROC"
        ["Morocco", "MA"]
      when "MARTINIQUE"
        ["Martinique", "MQ"]
      when "MAURITANIE"
        ["Mauritania", "MR"]
      when "MAYOTTE"
        ["Mayotte", "YT"]
      when "MEXIQUE"
        ["Mexico", "MX"]
      when "MICRONESIE"
        ["Federated States of Micronesia", "FM"]
      when "MONACO"
        ["Monaco", "MC"]
      when "NEPAL"
        ["Nepal", "NP"]
      when "NIGER"
        ["Niger", "NE"]
      when "NIGERIA"
        ["Nigeria", "NG"]
      when "NORVEGE"
        ["Norway", "NO"]
      when "NOUVELLE ZELANDE"
        ["New Zealand", "NZ"]
      when "PAKISTAN"
        ["Pakistan", "PK"]
      when "PANAMA"
        ["Panama", "PA"]
      when "PAYS BAS"
        ["Netherlands", "NL"]
      when "PEROU"
        ["Peru", "PE"]
      when "PHILIPPINES"
        ["Philippines", "PH"]
      when "POLOGNE"
        ["Poland", "PL"]
      when "PORTUGAL"
        ["Portugal", "PT"]
      when "QATAR"
        ["Qatar", "QA"]
      when "REPUBLIQUE CENTRAFRICAINE"
        ["Central African Republic", "CF"]
      when "REPUBLIQUE DEMOCRATIQUE DU CONGO"
        ["The Democratic Republic of the Congo", "CD"]
      when "REPUBLIQUE DOMINICAINE"
        ["Dominican Republic", "DO"]
      when "REPUBLIQUE TCHEQUE"
        ["Czech Republic", "CZ"]
      when "ROUMANIE"
        ["Romania", "RO"]
      when "ROYAUME-UNI"
        ["United Kingdom", "GB"]
      when "RUSSIE"
        ["Russian Federation", "RU"]
      when "SAINT BARTHELEMY"
        ["Saint Barthélemy", "BL"]
      when "SAINT MARTIN"
        ["Saint Martin (French part)", "MF"]
      when "SAINT MARTIN (PARTIE NEERLANDAISE)"
        ["Sint Maarten (Dutch part)", "SX"]
      when "SAINT VINCENT ET LES GRENADINES"
        ["Saint Vincent and the Grenadines", "VC"]
      when "SENEGAL"
        ["Senegal", "SN"]
      when "SERBIE"
        ["Serbia", "RS"]
      when "SEYCHELLES"
        ["Seychelles", "SC"]
      when "SINGAPOUR"
        ["Singapore", "SG"]
      when "SLOVAQUIE"
        ["Slovakia", "SK"]
      when "SLOVENIE"
        ["Slovenia", "SI"]
      when "SRI LANKA  CEYLAN"
        ["Sri Lanka", "LK"]
      when "SUEDE"
        ["Sweden", "SE"]
      when "SUISSE"
        ["Switzerland", "CH"]
      when "TAIWAN"
        ["Taiwan", "TW"]
      when "TCHAD"
        ["Chad", "TD"]
      when "THAILANDE"
        ["Thailand", "TH"]
      when "TOGO"
        ["Togo", "TG"]
      when "TRINITE ET TOBAGO"
        ["Trinidad and Tobago", "TT"]
      when "TUNISIE"
        ["Tunisia", "TN"]
      when "TURQUIE"
        ["Turkey", "TR"]
      when "UKRAINE"
        ["Ukraine", "UA"]
      when "URUGUAY"
        ["Uruguay", "UY"]
      when "VENEZUELA"
        ["Venezuela", "VE"]        
      when "VIET NAM"
        ["Viet Nam", "VN"]
      when "YEMEN"
        ["Yemen", "YE"]
      when "", " "
        ["France", "FR"]        
      else
        begin
          raise "#{row["L7_NORMALISEE"]}: #{row}"
        rescue Exception => e
          Bugsnag.notify(e)
        end
        ["France", "FR"]
      end
    end
end
