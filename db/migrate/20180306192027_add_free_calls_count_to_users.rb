class AddFreeCallsCountToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :free_calls_count, :integer, default: 100
  end
end
