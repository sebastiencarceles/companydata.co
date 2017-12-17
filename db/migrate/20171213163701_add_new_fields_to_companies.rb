class AddNewFieldsToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :address_line_3, :string
    add_column :companies, :address_line_4, :string
    add_column :companies, :address_line_5, :string
    add_column :companies, :cedex, :string
    add_column :companies, :quality, :string
    add_column :companies, :revenue, :string
    rename_column :companies, :company_type, :legal_form
  end
end
