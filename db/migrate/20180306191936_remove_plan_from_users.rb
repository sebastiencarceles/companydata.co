class RemovePlanFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :plan, :string
  end
end
