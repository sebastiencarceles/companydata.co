# frozen_string_literal: true

namespace :activities do
  task seed: :environment do
    Rails.logger.info "Seed activities"
    CSV.foreach("db/seeds/activities.csv", headers: true).each do |row|
      Activity.find_or_create_by(country_code: row["country_code"], code: row["code"], label_fr: row["label_fr"])
    end
    Rails.logger.info "Done"
  end
end
