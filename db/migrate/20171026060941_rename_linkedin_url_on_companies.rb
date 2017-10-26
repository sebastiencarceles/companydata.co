class RenameLinkedinUrlOnCompanies < ActiveRecord::Migration[5.1]
  def change
    rename_column :companies, :linkedin_url, :source_url
  end
end
