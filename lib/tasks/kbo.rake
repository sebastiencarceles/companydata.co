# frozen_string_literal: true

require "csv"

namespace :kbo do
  task download: :environment do
    Zip::File.open(download_zipped_source("KboOpenData_0051_2018_04_Full")) do |zip_file|
      zip_file.each do |entry|
        Rails.logger.info "Unzip file #{entry.name}"
        begin
          entry.extract(entry.name)
        rescue Zip::DestinationFileExistsError => e
          Rails.logger.warn "Destination file already exists"
        end
      end
    end
  end

  task import_codes: :environment do
    import_from("code.csv", KboCode) do |row|
      { 
        category: row["Category"],
        code: row["Code"],
        language: row["Language"],
        description: row["Description"]
      }
    end
  end

  task import_enterprises: :environment do    
    import_from("enterprise.csv", KboEnterprise) do |row|
      { 
        enterprise_number: row["EnterpriseNumber"],
        type_of_enterprise: row["TypeOfEnterprise"],
        juridical_form: row["JuridicalForm"],
        start_date: row["StartDate"]
      }
    end
  end

  task import_establishments: :environment do
    import_from("establishment.csv", KboEstablishment) do |row|
      { 
        enterprise_number: row["EnterpriseNumber"],
        establishment_number: row["EstablishmentNumber"],
        start_date: row["StartDate"]
      }
    end
  end

  task import_denominations: :environment do
    import_from("denomination.csv", KboDenomination) do |row|
      {
        entity_number: row["EntityNumber"],
        language: row["Language"],
        type_of_denomination: row["TypeOfDenomination"],
        denomination: row["Denomination"]
      }
    end
  end

  task import_addresses: :environment do
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

  task import_activities: :environment do
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

  task import_contacts: :environment do
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
    KboAddress.find_each do |address|
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

      attributes[:founded_at] = get_founded_at(establishment)
      attributes[:founded_at] ||= get_founded_at(enterprise)

      attributes[:registration_1] = enterprise.enterprise_number
      
      attributes[:registration_2] = establishment&.establishment_number

      attributes[:quality] = get_quality(address)
      
      attributes[:name] = get_name(establishment)
      attributes[:name] ||= get_name(enterprise)
      error(address, "unable to find a name") unless attributes[:name]

      attributes[:website] = get_website(establishment)
      attributes[:website] ||= get_website(enterprise)

      attributes[:email] = get_email(establishment)
      attributes[:email] ||= get_email(enterprise)

      attributes[:phone] = get_phone(establishment)
      attributes[:phone] ||= get_phone(enterprise)

      attributes[:legal_form] = get_legal_form(address, enterprise)

      attributes[:activity_code] = get_activity_code(establishment)
      attributes[:activity_code] ||= get_activity_code(enterprise)

      # t.string "address_line_1"
      # t.string "address_line_2"
      # t.string "zipcode"
      # t.string "city"
      # t.string "department_code"
      # t.string "department"
      # t.string "region"
      # t.string "country"
      # t.string "address_line_3"
      # t.string "address_line_4"
      # t.string "address_line_5"
      # t.string "cedex"
      # t.float "lat"
      # t.float "lng"
      # t.datetime "geolocalized_at"
      # t.string "civility"
      # t.string "first_name"
      # t.string "last_name"
      # t.string "linkedin"
      # t.string "facebook"
      # t.string "twitter"
      # t.string "crunchbase"
      # t.string "country_code"

      pp attributes
    end
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
        error(address, "unable to find corresponding JuridicalForm #{enterprise.juridical_form} for FR") unless code
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
      path = "db/raw/kbo/#{filename}.zip"
      return path if File.exists?(path)

      source = "https://s3.eu-west-3.amazonaws.com/companydata-production/belgium/#{filename}.zip"
      Rails.logger.info "Download #{source} into #{path}"
      IO.copy_stream(open(source), path)
      return path
    end
end
