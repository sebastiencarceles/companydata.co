class AddIndexToCodes < ActiveRecord::Migration[5.1]
  def change
    add_index :kbo_codes, [:category, :code, :language]
  end
end
