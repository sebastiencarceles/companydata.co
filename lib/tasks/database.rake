# frozen_string_literal: true

namespace :database do
  desc "Eventually fix the sequence ID bug of database"
  task fix_sequence_id: :environment do
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
end
