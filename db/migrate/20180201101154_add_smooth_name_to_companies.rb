class AddSmoothNameToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :smooth_name, :string
    add_index :companies, :smooth_name
    add_index :companies, :name
  end
end
