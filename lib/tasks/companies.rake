require 'yaml'

namespace :companies do
  task dump: :environment do
    File.open("db/data/companies.yml", "w") do |file|
      Company.all.map do |company|
        puts "Dump #{company.slug}"
        company_data = company.attributes.except("id", "created_at", "updated_at") 
        file.write(company_data.to_yaml)  
      end
    end
  end

  task load: :environment do
    YAML.load_stream(File.read 'db/data/companies.yml') do |company_data|
      puts "Create / update #{company_data['slug']}"
      Company.find_or_create_by(slug: company_data["slug"]) { |company| company.attributes = company_data }
    end
  end
end