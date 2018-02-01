class AddYearClosingDateIndexOnFinancialYears < ActiveRecord::Migration[5.1]
  def change
    add_index :financial_years, [:year, :closing_date]
  end
end
