class AddFieldsToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :registration_1, :string
    add_column :companies, :registration_2, :string
    add_column :companies, :activity_code, :string
    add_column :companies, :address_line_1, :string
    add_column :companies, :address_line_2, :string
    add_column :companies, :zipcode, :string
    add_column :companies, :city, :string
    add_column :companies, :department_code, :string
    add_column :companies, :department, :string
    add_column :companies, :region, :string
    add_column :companies, :founded_at, :date
    add_column :companies, :geolocation, :string
  end
end
