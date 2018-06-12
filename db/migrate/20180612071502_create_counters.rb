class CreateCounters < ActiveRecord::Migration[5.1]
  def change
    create_table :counters do |t|
      t.references :user, foreign_key: true
      t.date :date
      t.boolean :billed, default: false
      t.integer :value, default: 0

      t.timestamps
    end

    add_index :counters, :date
  end
end
