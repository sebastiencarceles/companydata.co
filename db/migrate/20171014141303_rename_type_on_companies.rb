class RenameTypeOnCompanies < ActiveRecord::Migration[5.1]
  def change
    rename_column :companies, :type, :company_type
  end
end
