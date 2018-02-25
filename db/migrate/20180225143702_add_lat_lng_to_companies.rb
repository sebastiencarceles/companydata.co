class AddLatLngToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :lat, :float
    add_column :companies, :lng, :float

    Company.where.not(geolocation: [nil, ""]).find_each do |company|
      lat = company.geolocation.split(",").first.strip.to_f 
      lng = company.geolocation.split(",").last.strip.to_f
      company.update_columns(lat: lat, lng: lng) if lat != 0 && lng != 0
    end
  end
end
