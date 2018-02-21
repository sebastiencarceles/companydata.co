# frozen_string_literal: true

require "open-uri"

namespace :companies do
  task dump: :environment do
    DataYaml.dump("db/raw", Company)
    DataYaml.dump("db/raw", FinancialYear)
  end

  task load: :environment do
    DataYaml.load("db/raw", Company)
    DataYaml.load("db/raw", FinancialYear)
  end

  task load_from_s3: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    subfolder = ARGV[1]
    fail "No subfolder given" if subfolder.nil?

    indir_url = "https://s3.eu-west-3.amazonaws.com/company-io/#{subfolder}"
    DataYaml.load_from_s3(indir_url, Company)
    DataYaml.load_from_s3(indir_url, FinancialYear)
  end

  task dedupe: :environment do
    Rails.logger.info "Deduplicate companies"
    scope = Company.where.not(registration_1: nil).where.not(registration_2: nil).where(country: "France")
    scope.select(:registration_1, :registration_2).group(:registration_1, :registration_2).having("count(*) > 1").size.each do |k, v|
      raise "only one!" if v <= 1
      reg1 = k.first
      reg2 = k.last
      raise "reg1 is nil!" if reg1.nil?
      raise "reg2 is nil!" if reg2.nil?
      duplicates = Company.where(registration_1: reg1, registration_2: reg2).map { |company| company }
      first_one = duplicates.shift
      Rails.logger.info "Destroy #{duplicates.count} entries"
      duplicates.each { |duplicate| duplicate.destroy! }
    end
  end

  task reindex: :environment do
    Rails.logger.info "Reindex companies"
    Company.search_index.clean_indices
    Company.reindex
  end

  task reslug: :environment do
    Rails.logger.info "Reslug companies"
    Company.where(slug: nil).find_each do |company|
      counter = 1
      slug = company.name.parameterize
      while Company.exists?(slug: slug) do
        slug = company.name.parameterize.strip + "-" + counter.to_s
        counter += 1
      end
      company.update_columns(slug: slug)
      Rails.logger.info "Slugged company: #{slug}"
    end
  end

  task redepartment: :environment do
    Rails.logger.info "Recompute department"
    departments = {
      "": nil,
      "01": "Ain",
      "02": "Aisne",
      "03": "Allier",
      "04": "Alpes de Haute-Provence",
      "05": "Hautes-Alpes",
      "06": "Alpes-Maritimes",
      "07": "Ardêche",
      "08": "Ardennes",
      "09": "Ariège",
      "10": "Aube",
      "11": "Aude",
      "12": "Aveyron",
      "13": "Bouches-du-Rhône",
      "14": "Calvados",
      "15": "Cantal",
      "16": "Charente",
      "17": "Charente-Maritime",
      "18": "Cher",
      "19": "Corrèze",
      "2A": "Corse-du-Sud",
      "2B": "Haute-Corse",
      "21": "Côte-d'Or",
      "22": "Côtes d'Armor",
      "23": "Creuse",
      "24": "Dordogne",
      "25": "Doubs",
      "26": "Drôme",
      "27": "Eure",
      "28": "Eure-et-Loir",
      "29": "Finistère",
      "30": "Gard",
      "31": "Haute-Garonne",
      "32": "Gers",
      "33": "Gironde",
      "34": "Hérault",
      "35": "Île-et-Vilaine",
      "36": "Indre",
      "37": "Indre-et-Loire",
      "38": "Isère",
      "39": "Jura",
      "40": "Landes",
      "41": "Loir-et-Cher",
      "42": "Loire",
      "43": "Haute-Loire",
      "44": "Loire-Atlantique",
      "45": "Loiret",
      "46": "Lot",
      "47": "Lot-et-Garonne",
      "48": "Lozère",
      "49": "Maine-et-Loire",
      "50": "Manche",
      "51": "Marne",
      "52": "Haute-Marne",
      "53": "Mayenne",
      "54": "Meurthe-et-Moselle",
      "55": "Meuse",
      "56": "Morbihan",
      "57": "Moselle",
      "58": "Nièvre",
      "59": "Nord",
      "60": "Oise",
      "61": "Orne",
      "62": "Pas-de-Calais",
      "63": "Puy-de-Dôme",
      "64": "Pyrénées-Atlantiques",
      "65": "Hautes-Pyrénées",
      "66": "Pyrénées-Orientales",
      "67": "Bas-Rhin",
      "68": "Haut-Rhin",
      "69": "Rhône",
      "70": "Haute-Saône",
      "71": "Saône-et-Loire",
      "72": "Sarthe",
      "73": "Savoie",
      "74": "Haute-Savoie",
      "75": "Paris",
      "76": "Seine-Maritime",
      "77": "Seine-et-Marne",
      "78": "Yvelines",
      "79": "Deux-Sèvres",
      "80": "Somme",
      "81": "Tarn",
      "82": "Tarn-et-Garonne",
      "83": "Var",
      "84": "Vaucluse",
      "85": "Vendée",
      "86": "Vienne",
      "87": "Haute-Vienne",
      "88": "Vosges",
      "89": "Yonne",
      "90": "Territoire-de-Belfort",
      "91": "Essonne",
      "92": "Hauts-de-Seine",
      "93": "Seine-Saint-Denis",
      "94": "Val-de-Marne",
      "95": "Val-d'Oise",
      "97": "Outre-Mer",
      "98": "Outre-Mer",
      "99": nil
    }
    departments.each do |code, name|
      Company.where(department_code: code).where(department: [nil, ""]).update_all(department: name)
      Rails.logger.info "Update companies with department code #{code}: #{name}"
    end
  end

  task geocode: :environment do
    Rails.logger.info "Geocode 2500 companies"
    Company.where(geolocation: [nil, ""]).where.not(address_line_1: [nil, ""]).limit(2500).each do |company|
      full_address = [
        company.address_line_1,
        company.address_line_2,
        company.address_line_3,
        company.zipcode,
        company.city,
        company.country
      ].reject(&:blank?).join(", ")
      uri = URI.escape("https://maps.googleapis.com/maps/api/geocode/json?address=#{full_address}&key=#{Figaro.env.GOOGLE_API_KEY}")
      response = open(uri).read()
      results = JSON.parse(response)["results"]
      if results.any?
        lat = results.first["geometry"]["location"]["lat"]
        lng = results.first["geometry"]["location"]["lng"]
        if lat.present? && lng.present?
          company.update_columns(geolocation: [lat, lng].join(", "))
          Rails.logger.info "Update company #{company.id} with geolocation: #{[lat, lng].join(", ")}"
        else
          company.update_columns(geolocation: "unknown")
          Rails.logger.warn "No geolocation for company #{company.id}"
        end
      else
        company.update_columns(geolocation: "unknown")
        Rails.logger.warn "No result for company #{company.id}"
      end
    end
    Rails.logger.info "Done"
  end

  task create_vats: :environment do
    Rails.logger.info "Create Vat for each company"
    companies = Company.where(country: "France").where.not(registration_1: [nil, ""]).left_outer_joins(:vat).where(vats: { id: nil })
    companies.find_each do |company|
      key = ((12 + 3 * (company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
      vat_number = "FR#{key}#{company.registration_1}"
      company.create_vat(
        vat_number: vat_number,
        status: :in_progress
      )
      Rails.logger.info "Vat number created for company #{company.id}: #{vat_number}"
    end
    Rails.logger.info "Done"
  end
end
