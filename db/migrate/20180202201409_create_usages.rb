class CreateUsages < ActiveRecord::Migration[5.1]
  def change
    create_table :usages do |t|
      t.integer :year
      t.integer :month
      t.integer :count, default: 0
      t.integer :limit
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :usages, [:user_id, :year, :month]
  end
end
