class CreateFinancialYears < ActiveRecord::Migration[5.1]
  def change
    create_table :financial_years do |t|
      t.string :year
      t.string :currency
      t.integer :revenue, limit: 8
      t.integer :income, limit: 8
      t.integer :staff
      t.integer :duration
      t.date :closing_date
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
