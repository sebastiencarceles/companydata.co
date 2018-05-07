# frozen_string_literal: true

require "csv"

namespace :kbo do
  task import: :environment do
    Zip::File.open(download_zipped_source("KboOpenData_0051_2018_04_Full")) do |zip_file|
      zip_file.each do |entry|
        Rails.logger.info "Unzip file #{entry.name}"
        begin
          entry.extract(entry.name)
        rescue Zip::DestinationFileExistsError => e
          Rails.logger.warn "Destination file already exists"
        end
      end

      import_codes
      import_enterprises
      import_establishments
      import_denominations
      import_addresses
      import_activities
      import_contacts
    end
  end

  def import_codes
    import_from("code.csv", KboCode) do |row|
      {
        category: row["Category"],
        code: row["Code"],
        language: row["Language"],
        description: row["Description"]
      }
    end
  end

  def import_enterprises
    import_from("enterprise.csv", KboEnterprise) do |row|
      {
        enterprise_number: row["EnterpriseNumber"],
        type_of_enterprise: row["TypeOfEnterprise"],
        juridical_form: row["JuridicalForm"],
        start_date: row["StartDate"]
      }
    end
  end

  def import_establishments
    import_from("establishment.csv", KboEstablishment) do |row|
      {
        enterprise_number: row["EnterpriseNumber"],
        establishment_number: row["EstablishmentNumber"],
        start_date: row["StartDate"]
      }
    end
  end

  def import_denominations
    import_from("denomination.csv", KboDenomination) do |row|
      {
        entity_number: row["EntityNumber"],
        language: row["Language"],
        type_of_denomination: row["TypeOfDenomination"],
        denomination: row["Denomination"]
      }
    end
  end

  def import_addresses
    import_from("address.csv", KboAddress) do |row|
      {
        entity_number: row["EntityNumber"],
        type_of_address: row["TypeOfAddress"],
        country: row["CountryFR"],
        zipcode: row["Zipcode"],
        municipality: row["MunicipalityFR"],
        street: row["StreetFR"],
        house_number: row["HouseNumber"],
        box: row["Box"],
        extra_address_info: row["ExtraAddressInfo"],
        date_striking_off: row["DateStrikingOff"]
      }
    end
  end

  def import_activities
    import_from("activity.csv", KboActivity) do |row|
      {
        entity_number: row["EntityNumber"],
        activity_group: row["ActivityGroup"],
        nace_version: row["NaceVersion"],
        nace_code: row["NaceCode"],
        classification: row["Classification"]
      }
    end
  end

  def import_contacts
    import_from("contact.csv", KboContact) do |row|
      {
        entity_number: row["EntityNumber"],
        entity_contact: row["EntityContact"],
        contact_type: row["ContactType"],
        value: row["Value"]
      }
    end
  end

  task create_companies: :environment do
    KboAddress.where(date_striking_off: nil).find_each do |address|
      attributes = {}
      attributes[:source_url] = "https://kbopub.economie.fgov.be/kbo-open-data"

      case address.entity_number.length
      when 12
        enterprise = KboEnterprise.find_by_enterprise_number(address.entity_number)
      when 13
        establishment = KboEstablishment.find_by_establishment_number(address.entity_number)
        enterprise = KboEnterprise.find_by_enterprise_number(establishment.enterprise_number)
      else
        error(address, "unknown entity number format #{address.entity_number}")
      end

      attributes[:name] = get_name(establishment)
      attributes[:name] ||= get_name(enterprise)
      if attributes[:name].blank? || attributes[:name] == "-"
        Rails.logger.error("Unable to find a valid name for address #{address.id}")
        next
      end

      attributes[:founded_at] = get_founded_at(establishment)
      attributes[:founded_at] ||= get_founded_at(enterprise)

      attributes[:registration_1] = enterprise.enterprise_number

      attributes[:registration_2] = establishment&.establishment_number

      attributes[:quality] = get_quality(address)

      attributes[:website] = get_website(establishment)
      attributes[:website] ||= get_website(enterprise)

      attributes[:email] = get_email(establishment)
      attributes[:email] ||= get_email(enterprise)

      attributes[:phone] = get_phone(establishment)
      attributes[:phone] ||= get_phone(enterprise)

      attributes[:legal_form] = get_legal_form(address, enterprise)

      attributes[:activity_code] = get_activity_code(establishment)
      attributes[:activity_code] ||= get_activity_code(enterprise)

      attributes[:address_line_1] = [address.house_number.presence, address.box.presence].compact.join(" boîte ")
      attributes[:address_line_2] = address.street
      attributes[:address_line_3] = address.extra_address_info
      attributes[:zipcode] = address.zipcode
      attributes[:city] = address.municipality
      country, country_code = get_country_and_country_code(address)
      attributes[:country] = country
      attributes[:country_code] = country_code

      Company.find_or_create_by!(attributes)
    end
    Rails.logger.info("Done")
  end

  private

    def get_founded_at(entity)
      return nil unless entity

      Date.parse(entity.start_date, "%d-%m-%Y")
    end

    def get_quality(address)
      case address.type_of_address
      when "REGO"
        "headquarter"
      when "OBAD", "BAET", "ABBR"
        "branch"
      else
        error(address, "unknown type of address #{address.type_of_address}")
      end
    end

    def get_name(entity)
      return nil unless entity

      %w[1 2 3 4 0].each do |language| # Language priority: FR, NL, DE, EN, unknown
        %w[001 003 002].each do |type| # Type of denomination priority: social, commecial, shorten
          result = KboDenomination.where(entity_number: entity.entity_number, language: language, type_of_denomination: type).first
          return result.denomination if result
        end
      end

      return nil
    end

    def get_website(entity)
      get_contact_value(entity, "WEB")
    end

    def get_email(entity)
      get_contact_value(entity, "EMAIL")
    end

    def get_phone(entity)
      get_contact_value(entity, "TEL")
    end

    def get_contact_value(entity, contact_type)
      return nil unless entity

      KboContact.where(entity_number: entity.entity_number, contact_type: "WEB").first&.value
    end

    def get_legal_form(address, enterprise)
      case enterprise.type_of_enterprise
      when "1"
        "Personne physique"
      when "2", "0"
        code = KboCode.where(category: "JuridicalForm", code: enterprise.juridical_form, language: "FR").first
        return nil unless code
        code.description
      else
        error(address, "unknown type of enterprise #{enterprise.type_of_enterprise}")
      end
    end

    def get_activity_code(entity)
      return nil unless entity

      activity = KboActivity.where(entity_number: entity.entity_number, nace_version: "2008", classification: "MAIN").first
      activity ||= KboActivity.where(entity_number: entity.entity_number, nace_version: "2003", classification: "MAIN").first
      return nil unless activity

      "Nace#{activity.nace_version}-#{activity.nace_code}"
    end

    def error(address, message)
      fail "Error for address #{address.id}: #{message}"
    end

    def import_from(filename, model)
      Rails.logger.info "Import #{filename}"
      model.delete_all
      batch = []
      CSV.foreach(filename, headers: true) do |row|
        batch << model.new(yield row)
        if batch.count >= 10000
          model.import!(batch)
          Rails.logger.info "Total #{model.to_s} in database: #{model.count}"
          batch.clear
        end
      end
      model.import!(batch)
      Rails.logger.info "Total #{model.to_s} in database: #{model.count}"
    end

    def download_zipped_source(filename)
      path_dir = "db/raw/kbo"

      path = File.join(path_dir, "#{filename}.zip")
      return path if File.exists?(path)

      source = "https://s3.eu-west-3.amazonaws.com/companydata-production/belgium/#{filename}.zip"
      Rails.logger.info "Download #{source} into #{path}"
      FileUtils.mkdir_p(path_dir)
      IO.copy_stream(open(source), path)
      return path
    end

    def get_country_and_country_code(address)
      case address.country
      when nil, ""
        ["Belgium", "BE"]
      when "Afrique du Sud /Rép. d'/"
        ["South Africa", "ZA"]
      when "Albanie"
        ["Albania", "AL"]
      when "Algérie"
        ["Algeria", "DZ"]
      when "Allemagne", "Allemagne ( Rép. dém. )", "Allemagne (Rép. dém.)", "Allemagne (Rép.féd.)"
        ["Germany", "DE"]
      when "Andorre"
        ["Andorra", "AD"]
      when "Angola"
        ["Angola", "AO"]
      when "Anguilla(R.U.)"
        ["Anguilla", "AI"]
      when "Antigua", "Antigua(R.U.)"
        ["Antigua and Barbuda", "AG"]
      when "Arabie Saoudite"
        ["Saudi Arabia", "SA"]
      when "Argentine"
        ["Argentina", "AR"]
      when "Arménie ( Rép. )"
        ["Armenia", "AM"]
      when "Australie"
        ["Australia", "AU"]
      when "Autriche"
        ["Austria", "AT"]
      when "Azerbaïdjan ( Rép. )"
        ["Azerbaijan", "AZ"]
      when "Bahamas"
        ["Bahamas", "BS"]
      when "Bahrein"
        ["Bahrain", "BH"]
      when "Bangladesh"
        ["Bangladesh", "BD"]
      when "Barbade"
        ["Barbados", "BB"]
      when "Belize", "Belize(R.U.)"
        ["Belize", "BZ"]
      when "Bermudes"
        ["Bermuda", "BM"]
      when "Biélorussie ( Rép. )"
        ["Belarus", "BY"]
      when "Bolivie"
        ["Bolivia", "BO"]
      when "Bosnie-Herzégovine (Rép. de)"
        ["Bosnia and Herzegovina", "BA"]
      when "Botswana"
        ["Botswana", "BW"]
      when "Brunei"
        ["Brunei Darussalam", "BN"]
      when "Brésil"
        ["Brazil", "BR"]
      when "Bulgarie"
        ["Bulgaria", "BG"]
      when "Burkina Faso"
        ["Burkina Faso", "BF"]
      when "Burundi"
        ["Burundi", "BI"]
      when "Bénin(Rép. pop. du)"
        ["Benin", "BJ"]
      when "Cambodge", "Cambodge (Royaume du)"
        ["Cambodia", "KH"]
      when "Cameroun"
        ["Cameroon", "CM"]
      when "Canada"
        ["Canada", "CA"]
      when "Caïmanes(R.U.)"
        ["Cayman Islands", "KY"]
      when "Chili"
        ["Chile", "CL"]
      when "Chine (Hong-Kong SAR)"
        ["Hong Kong", "HK"]
      when "Chine (Macao SAR)"
        ["Macao", "MO"]
      when "Chine /Rép. pop./"
        ["China", "CN"]
      when "Chine-Taïwan ( Rép. de )"
        ["Taiwan", "TW"]
      when "Chypre"
        ["Cyprus", "CY"]
      when "Colombie"
        ["Colombia", "CO"]
      when "Congo (Rép. dém.)"
        ["Democratic Republic of the Congo", "CD"]
      when "Congo(Rép. pop. du)"
        ["Congo", "CG"]
      when "Corée du Nord ( Rép. de )"
        ["Democratic People's Republic of Korea", "KP"]
      when "Corée du Sud ( Rép. de )"
        ["Republic of Korea", "KR"]
      when "Costa Rica"
        ["Costa Rica", "CR"]
      when "Croatie ( Rép. de )"
        ["Croatia", "HR"]
      when "Cuba"
        ["Cuba", "CU"]
      when "Côte d'Ivoire"
        ["Côte d'Ivoire", "CI"]
      when "Danemark"
        ["Denmark", "DK"]
      when "Dominicaine /Rép./"
        ["Dominican Republic", "DO"]
      when "Dominique (République)"
        ["Dominica", "DM"]
      when "El Salvador"
        ["El Salvador", "SV"]
      when "Emirats arabes unis"
        ["United Arab Emirates", "AE"]
      when "Equateur"
        ["Ecuador", "EC"]
      when "Espagne"
        ["Spain", "ES"]
      when "Estonie"
        ["Estonia", "EE"]
      when "Etats-Unis d'Amérique"
        ["United States", "US"]
      when "Ethiopie"
        ["Ethiopia", "ET"]
      when "Finlande"
        ["Finland", "FI"]
      when "France"
        ["France", "FR"]
      when "Gabon"
        ["Gabon", "GA"]
      when "Gambie"
        ["Gambia", "GM"]
      when "Ghana"
        ["Ghana", "GH"]
      when "Gibraltar"
        ["Gibraltar", "GI"]
      when "Grande-Bretagne"
        ["United Kingdom", "GB"]
      when "Grèce"
        ["Greece", "GR"]
      when "Guam"
        ["Guam", "GU"]
      when "Guatémala"
        ["Guatemala", "GT"]
      when "Guinée"
        ["Guinea", "GN"]
      when "Guinée-Bissau"
        ["Guinea-Bissau", "GW"]
      when "Guyane"
        ["Guyana", "GY"]
      when "Guyane Française"
        ["French Guiana", "GF"]
      when "Géorgie ( Rép. )"
        ["Georgia", "GE"]
      when "Hawaï"
        ["United States", "US"]
      when "Haïti"
        ["Haiti", "HT"]
      when "Honduras"
        ["Honduras", "HN"]
      when "Hong Kong(R.U.)", "Hong-Kong"
        ["Hong Kong", "HK"]
      when "Hongrie ( Rép. )", "Hongrie(République)"
        ["Hungary", "HU"]
      when "Iles Marshall (République des)"
        ["Marshall Islands", "MH"]
      when "Iles Turks et Caicos"
        ["Turks and Caicos Islands", "TC"]
      when "Iles Vierges"
        ["Virgin Islands", "VI"]
      when "Inde"
        ["India", "IN"]
      when "Indonésie"
        ["Indonesia", "ID"]
      when "Irak"
        ["Iraq", "IQ"]
      when "Iran"
        ["Islamic Republic of Iran", "IR"]
      when "Irlande /Eire/"
        ["Ireland", "IE"]
      when "Islande"
        ["Iceland", "IS"]
      when "Israël"
        ["Israel", "IL"]
      when "Italie"
        ["Italy", "IT"]
      when "Jamaïque"
        ["Jamaica", "JM"]
      when "Japon"
        ["Japan", "JP"]
      when "Jordanie"
        ["Jordan", "JO"]
      when "Kazakhstan ( Rép. )"
        ["Kazakhstan", "KZ"]
      when "Kenya"
        ["Kenya", "KE"]
      when "Kirghizie ( Rep. )"
        ["Kyrgyzstan", "KG"]
      when "Kitts and Nevis(R.U.)"
        ["Saint Kitts and Nevis", "KN"]
      when "Kosovo"
        ["Kosovo", "XK"]
      when "Koweit/Principauté de/"
        ["Kuwait", "KW"]
      when "Le Groenland(D.K.)"
        ["Greenland", "GL"]
      when "Lesotho"
        ["Lesotho", "LS"]
      when "Lettonie"
        ["Latvia", "LV"]
      when "Liban"
        ["Lebanon", "LB"]
      when "Libye"
        ["Libya", "LY"]
      when "Libéria"
        ["Liberia", "LR"]
      when "Liechtenstein"
        ["Liechtenstein", "LI"]
      when "Lituanie"
        ["Lithuania", "LT"]
      when "Luxembourg (Grand-Duché)"
        ["Luxembourg", "LU"]
      when "Macao"
        ["Macao", "MO"]
      when "Macédoine (Ex-Rép. yougoslave de)"
        ["Former Yugoslav Republic of Macedonia", "MK"]
      when "Malaisie"
        ["Malaysia", "MY"]
      when "Maldives"
        ["Maldives", "MV"]
      when "Mali"
        ["Mali", "ML"]
      when "Malte"
        ["Malta", "MT"]
      when "Maroc"
        ["Morocco", "MA"]
      when "Maurice /Ile/"
        ["Mauritius", "MU"]
      when "Mauritanie /Rép. Islamique de/"
        ["Mauritania", "MR"]
      when "Mexique"
        ["Mexico", "MX"]
      when "Moldavie ( Rép. )"
        ["Republic of Moldova", "MD"]
      when "Monaco /Principauté/"
        ["Monaco", "MC"]
      when "Mongolie(Rép.pop.de.)"
        ["Mongolia", "MN"]
      when "Monténégro"
        ["Montenegro", "ME"]
      when "Myanmar (Union de)"
        ["Myanmar", "MM"]
      when "Namibie"
        ["Namibia", "NA"]
      when "Nauru"
        ["Nauru", "NR"]
      when "Nepal"
        ["Nepal", "NP"]
      when "Ngwane (Royaume du Swaziland)"
        ["Swaziland", "SZ"]
      when "Nicaragua"
        ["Nicaragua", "NI"]
      when "Niger"
        ["Niger", "NE"]
      when "Nigéria(Rép. Féder.)"
        ["Nigeria", "NG"]
      when "Niue-ile(N-Z.)"
        ["Niue", "NU"]
      when "Norvège"
        ["Norway", "NO"]
      when "Nouvelle-Calédonie"
        ["New Caledonia", "NC"]
      when "Nouvelle-Zélande"
        ["New Zealand", "NZ"]
      when "Ouganda"
        ["Uganda", "UG"]
      when "Ouzbékistan ( Rép. )"
        ["Uzbekistan", "UZ"]
      when "Pakistan"
        ["Pakistan", "PK"]
      when "Panama"
        ["Panama", "PA"]
      when "Paraguay"
        ["Paraguay", "PY"]
      when "Pays-Bas"
        ["Netherlands", "NL"]
      when "Philippines"
        ["Philippines", "PH"]
      when "Pitcairn(terr.dép.du R.U.)"
        ["Pitcairn", "PN"]
      when "Pologne ( Rép. )", "Pologne(République)"
        ["Poland", "PL"]
      when "Polynésie"
        ["French Polynesia", "PF"]
      when "Porto-Rico(Ile de)"
        ["Puerto Rico", "PR"]
      when "Portugal"
        ["Portugal", "PT"]
      when "Pérou"
        ["Peru", "PE"]
      when "Qatar"
        ["Qatar", "QA"]
      when "Rhodésie"
        ["Zimbabwe", "ZW"]
      when "Roumanie"
        ["Romania", "RO"]
      when "Russie ( Fédération de )", "Union d.Rép.Soc.Soviét."
        ["Russian Federation", "RU"]
      when "Rwanda /Rép./"
        ["Rwanda", "RW"]
      when "Rép. Arabe d'Egypte"
        ["Egypt", "EG"]
      when "Rép.démocrat. de Madagascar"
        ["Madagascar", "MG"]
      when "République Centrafricaine"
        ["Central African Republic", "CF"]
      when "République Slovaque"
        ["Slovakia", "SK"]
      when "République Tchèque", "Tchécoslovaquie"
        ["Czech Republic", "CZ"]
      when "République socialiste du Vietnam"
        ["Viet Nam", "VN"]
      when "Réunion"
        ["Réunion", "RE"]
      when "Saint-Marin"
        ["San Marino", "SM"]
      when "Saint-Vincent"
        ["Saint Vincent and the Grenadines", "VC"]
      when "Samoa occidentales"
        ["Samoa", "WS"]
      when "Serbie"
        ["Serbia", "RS"]
      when "Seychelles (Iles)", "Seychelles(Iles)"
        ["Seychelles", "SC"]
      when "Singapour"
        ["Singapore", "SG"]
      when "Slovénie ( Rép. de )"
        ["Slovenia", "SI"]
      when "Somalie /Rép./"
        ["Somalia", "SO"]
      when "Sri Lanka"
        ["Sri Lanka", "LK"]
      when "St. Kitts et Nevis"
        ["Saint Kitts and Nevis", "KN"]
      when "Suisse"
        ["Switzerland", "CH"]
      when "Sultanat d'Oman"
        ["Oman", "OM"]
      when "Surinam"
        ["Suriname", "SR"]
      when "Suède"
        ["Sweden", "SE"]
      when "Swaziland"
        ["Swaziland", "SZ"]
      when "Syrie /Rép. Arabe Syrienne/"
        ["Syrian Arab Republic", "SY"]
      when "Sénégal"
        ["Senegal", "SN"]
      when "Tanzanie(Rép.Unie de)"
        ["United Republic of Tanzania", "TZ"]
      when "Tchad"
        ["Chad", "TD"]
      when "Thaïlande"
        ["Thailand", "TH"]
      when "Togo"
        ["Togo", "TG"]
      when "Tunisie"
        ["Tunisia", "TN"]
      when "Turkménistan ( Rép. )"
        ["Turkmenistan", "TM"]
      when "Turquie"
        ["Turkey", "TR"]
      when "Tuvalu"
        ["Tuvalu", "TV"]
      when "Ukraine ( Rép. )"
        ["Ukraine", "UA"]
      when "Uruguay"
        ["Uruguay", "UY"]
      when "Urundi"
        ["Burundi", "BI"]
      when "Vanuatu"
        ["Vanuatu", "VU"]
      when "Vénézuéla"
        ["Bolivarian Republic of Venezuela", "VE"]
      when "Zambie"
        ["Zambia", "ZM"]
      when "Zaïre (République du)"
        ["Democratic Republic of the Congo", "CD"]
      when "Pacifique/Iles du/", "Antilles françaises", "Antilles néerlandaises"
        ["Curaçao", "CW"]
      when "Indéterminé", "pas encore définitivement établie", "Rayé pour l'étranger", "Yougoslavie", "Yougoslavie (Serbie-Montenegro)", "Antilles américaines"
        ["Belgium", "BE"]
      when "Antilles britanniques"
        ["British Virgin Islands", "VG"]
      else
        error(address, "unknown country #{address.country}")
      end
    end
end
