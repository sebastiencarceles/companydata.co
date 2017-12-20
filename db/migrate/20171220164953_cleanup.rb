class Cleanup < ActiveRecord::Migration[5.1]
  def change
    drop_table :entreprises
    drop_table :tests
  end
end
