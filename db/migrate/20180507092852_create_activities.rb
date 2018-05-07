class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.string :country_code
      t.string :code
      t.string :label_fr

      t.timestamps
    end

    add_index :activities, [:country_code, :code]
  end
end
