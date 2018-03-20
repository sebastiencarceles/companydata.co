class RemoveHeadquarterInFromCompanies < ActiveRecord::Migration[5.1]
  def change
    remove_column :companies, :headquarter_in, :string
  end
end
