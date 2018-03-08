class AddStatusIndexOnVats < ActiveRecord::Migration[5.1]
  def change
    add_index :vats, :status
  end
end
