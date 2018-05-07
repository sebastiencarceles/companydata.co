class AddIndexToDenominations < ActiveRecord::Migration[5.1]
  def change
    add_index :kbo_denominations, [:entity_number, :language, :type_of_denomination], name: :number_language_type    
  end
end
