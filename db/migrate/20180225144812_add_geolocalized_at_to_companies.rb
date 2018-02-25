class AddGeolocalizedAtToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :geolocalized_at, :datetime
  end
end
