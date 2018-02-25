class AddLatLngToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :lat, :float
    add_column :companies, :lng, :float

    
  end
end
