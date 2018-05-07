class DeleteCodes < ActiveRecord::Migration[5.1]
  def change
    drop_table :codes
  end
end
