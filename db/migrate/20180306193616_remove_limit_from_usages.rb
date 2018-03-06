class RemoveLimitFromUsages < ActiveRecord::Migration[5.1]
  def change
    remove_column :usages, :limit, :integer
  end
end
