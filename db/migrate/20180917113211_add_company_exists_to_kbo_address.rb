class AddCompanyExistsToKboAddress < ActiveRecord::Migration[5.1]
  def change
    add_column :kbo_addresses, :company_exists, :boolean, default: false
  end
end
