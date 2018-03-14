class AddValueIndexToVats < ActiveRecord::Migration[5.1]
  def change
    add_index :vats, :value
  end
end
