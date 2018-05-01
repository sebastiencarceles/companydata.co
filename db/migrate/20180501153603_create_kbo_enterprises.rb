class CreateKboEnterprises < ActiveRecord::Migration[5.1]
  def change
    create_table :kbo_enterprises do |t|
      t.string :enterprise_number
      t.string :type_of_enterprise
      t.string :juridical_form
      t.string :start_date

      t.timestamps
    end
  end
end
