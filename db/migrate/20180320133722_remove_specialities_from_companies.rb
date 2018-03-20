class RemoveSpecialitiesFromCompanies < ActiveRecord::Migration[5.1]
  def change
    remove_column :companies, :specialities, :string
  end
end
