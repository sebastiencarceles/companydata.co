class CreateKboDenominations < ActiveRecord::Migration[5.1]
  def change
    create_table :kbo_denominations do |t|
      t.string :entity_number
      t.string :language
      t.string :type_of_denomination
      t.string :denomination

      t.timestamps
    end
  end
end
