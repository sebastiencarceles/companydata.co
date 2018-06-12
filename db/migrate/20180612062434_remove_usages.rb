class RemoveUsages < ActiveRecord::Migration[5.1]
  def change
    drop_table :usages
  end
end
