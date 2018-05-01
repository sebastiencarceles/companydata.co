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

    codes = load_codes
    import_enterprises(codes)
    import_establishements
    import_names

    unziped_files.each do |filename|
      Rails.logger.info "Delete file #{filename}"
      File.delete(filename)
    end
  end

  private

    def import_enterprises(codes)
      count = 0
      CSV.foreach("enterprise.csv", headers: true) do |row|
        count += 1

        registration_1 = row["EnterpriseNumber"]
        next if Company.where(registration_1: registration_1).exists?

        legal_form = case row["TypeOfEnterprise"]
        when "1"
          "Personne physique"
        when "2"
          codes["JuridicalForm"][row["JuridicalForm"]]
        end
        founded_at = Date.strptime(row["StartDate"], "%d-%m-%Y")
        company = Company.new(registration_1: registration_1, legal_form: legal_form, founded_at: founded_at)
        Rails.logger.info "#{count}/ Create company: #{registration_1} of legal form #{legal_form}, founded at #{founded_at}"
        company.save(validate: false)
      end
    end

    def import_establishements
      count = 0
      CSV.foreach("establishment.csv", headers: true) do |row|
        count += 1

        registration_1 = row["EnterpriseNumber"]
        registration_2 = row["EstablishmentNumber"]
        next if Company.where(registration_1: registration_1, registration_2: registration_2).exists?

        founded_at = Date.strptime(row["StartDate"], "%d-%m-%Y")
        company = Company.where(registration_1: registration_1, registration_2: nil)
        if company
          company.registration_2 = registration_2
          fail "compare the dates: #{founded_at} VS #{company.founded_at}" unless founded_at == company.founded_at
          Rails.logger.info "#{count}/ Update company: #{registration_1} with registration 2: #{registration_2}"
        else
          legal_form = Company.where(registration_1: registration_1).pluck(:legal_form).first
          company = Company.new(registration_1: registration_1, registration_2: registration_2, founded_at: founded_at, legal_form: legal_form)
          Rails.logger.info "#{count}/ Create company: #{registration_1} of legal form #{legal_form}, founded at #{founded_at}"
        end
        company.save(validate: false)
      end      
    end

    def import_names
      count = 0
      CSV.foreach("denomination.csv", headers: true) do |row|
        count += 1

        entity_number = row["EntityNumber"]
        case entity_number.length
        when 12
          registration_1 = entity_number
          
        when 14
          registration_2 = entity_number
        else
          fail "unknown entity number format: #{entity_number}"
        end

      end
    end

    def load_codes
      codes = Hash.new
      CSV.foreach("code.csv", headers: true) do |row|
        next unless row["Language"] == "FR"
        
        category = row["Category"]
        value = row["Code"]
        description = row["Description"]
        
        codes[category] = Hash.new unless codes.has_key?(category)
        codes[category][value] = description
      end
      codes
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