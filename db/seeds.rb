require "csv"

CSV.foreach("db/seeds/activities.csv", headers: true).each do |row|
  Activity.find_or_create_by(country_code: row["country_code"], code: row["code"], label_fr: row["label_fr"])
end