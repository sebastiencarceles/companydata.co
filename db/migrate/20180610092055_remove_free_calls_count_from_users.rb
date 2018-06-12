class RemoveFreeCallsCountFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :free_calls_count, :integer
  end
end
