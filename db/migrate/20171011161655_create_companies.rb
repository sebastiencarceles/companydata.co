class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :slug
      t.string :website
      t.integer :linkedin_id
      t.string :linkedin_url
      t.string :headquarter_in
      t.string :founded_in
      t.string :type
      t.string :category
      t.string :staff
      t.text :specialities
      t.text :presentation

      t.timestamps
    end

    add_index :companies, :slug, unique: true
  end
end
