class CreateVats < ActiveRecord::Migration[5.1]
  def change
    create_table :vats do |t|
      t.references :company, foreign_key: true
      t.string :vat_number
      t.string :status
      t.datetime :validated_at

      t.timestamps
    end
  end
end
