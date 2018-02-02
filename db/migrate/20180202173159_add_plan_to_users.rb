class AddPlanToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :plan, :string, default: "free"
  end
end
