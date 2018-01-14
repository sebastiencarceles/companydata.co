class RemoveTrigram < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.connection.execute("DROP EXTENSION pg_trgm CASCADE;")
  end
end
