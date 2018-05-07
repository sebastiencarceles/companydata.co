class CreateKboCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :kbo_codes do |t|
      t.string :category
      t.string :code
      t.string :language
      t.string :description

      t.timestamps
    end
  end
end
