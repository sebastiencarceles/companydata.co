class AddQualityIndexToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_index :companies, :quality
  end
end
