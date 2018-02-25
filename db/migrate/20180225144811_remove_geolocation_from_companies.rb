class RemoveGeolocationFromCompanies < ActiveRecord::Migration[5.1]
  def change
    remove_column :companies, :geolocation, :string
  end
end
