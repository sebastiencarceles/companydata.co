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

  private

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
