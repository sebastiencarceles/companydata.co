class RemoveFoundedInFromCompanies < ActiveRecord::Migration[5.1]
  def change
    remove_column :companies, :founded_in, :string
  end
end
