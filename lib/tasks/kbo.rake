require "csv"

namespace :kbo do
  task import: :environment do
    unziped_files = []
    Zip::File.open(download_zipped_source("KboOpenData_0051_2018_04_Full")) do |zip_file|
      zip_file.each do |entry|
        unziped_files << entry.name
        Rails.logger.info "Unzip file #{entry.name}"
        begin
          entry.extract(entry.name)
        rescue Zip::DestinationFileExistsError => e
          Rails.logger.warn "Destination file already exists"
        end
      end
    end

    import_codes
    import_enterprises
    import_establishments
    import_denominations
    import_addresses
    import_activities
    import_contacts

    unziped_files.each do |filename|
      Rails.logger.info "Delete file #{filename}"
      File.delete(filename)
    end
  end

  private

    def import_codes
      Rails.logger.info "Import codes"
      CSV.foreach("code.csv", headers: true) do |row|
        KboCode.find_or_create_by!(
          category: row["Category"],
          code: row["Code"],
          language: row["Language"],
          description: row["Description"]
        )
      end
    end

    def import_enterprises
      Rails.logger.info "Import enterprises"
      CSV.foreach("enterprise.csv", headers: true) do |row|
        KboEnterprise.find_or_create_by!(
          enterprise_number: row["EnterpriseNumber"],
          type_of_enterprise: row["TypeOfEnterprise"],
          juridical_form: row["JuridicalForm"],
          start_date: row["StartDate"]
        )
      end
    end

    def import_establishments
      Rails.logger.info "Import establishments"
      CSV.foreach("establishment.csv", headers: true) do |row|
        KboEstablishment.find_or_create_by!(
          enterprise_number: row["EnterpriseNumber"],
          establishment_number: row["EstablishmentNumber"],
          start_date: row["StartDate"]
        )
      end      
    end

    def import_denominations
      CSV.foreach("denomination.csv", headers: true) do |row|
        KboDenomination.find_or_create_by!(
          entity_number: row["EntityNumber"],
          language: row["Language"],
          type_of_denomination: row["TypeOfDenomination"],
          denomination: row["Denomination"]
        )
      end
    end

    def import_addresses
      CSV.foreach("address.csv", headers: true) do |row|
        KboAddress.find_or_create_by!(
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
        )
      end
    end

    def import_activities
      CSV.foreach("activity.csv", headers: true) do |row|
        KboActivity.find_or_create_by!(
          entity_number: row["EntityNumber"],
          activity_group: row["ActivityGroup"],
          nace_version: row["NaceVersion"],
          nace_code: row["NaceCode"],
          classification: row["Classification"]
        )
      end
    end
    
    def import_contacts
      CSV.foreach("contact.csv", headers: true) do |row|
        KboContact.find_or_create_by!(
          entity_number: row["EntityNumber"],
          entity_contact: row["EntityContact"],
          contact_type: row["ContactType"],
          value: row["Value"]
        )
      end
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