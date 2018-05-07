class AddIndexToActivities < ActiveRecord::Migration[5.1]
  def change
    add_index :kbo_activities, [:entity_number, :nace_version, :classification], name: :number_version_classification
  end
end
