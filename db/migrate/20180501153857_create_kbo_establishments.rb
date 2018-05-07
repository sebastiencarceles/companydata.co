class CreateKboEstablishments < ActiveRecord::Migration[5.1]
  def change
    create_table :kbo_establishments do |t|
      t.string :enterprise_number
      t.string :establishment_number
      t.string :start_date

      t.timestamps
    end
  end
end
