class CreateKboActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :kbo_activities do |t|
      t.string :entity_number
      t.string :activity_group
      t.string :nace_version
      t.string :nace_code
      t.string :classification

      t.timestamps
    end
  end
end
