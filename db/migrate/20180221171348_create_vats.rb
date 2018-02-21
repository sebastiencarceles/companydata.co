class CreateVats < ActiveRecord::Migration[5.1]
  def change
    create_table :vats do |t|
      t.references :company, foreign_key: true
      t.string :value
      t.string :status, default: "waiting_for_validation"
      t.datetime :validated_at
      t.string :country_code

      t.timestamps
    end
  end
end
