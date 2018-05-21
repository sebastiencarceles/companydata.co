# frozen_string_literal: true

require "open-uri"

namespace :data do
  task dump: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    ARGV.drop(1).each do |model|
      DataYaml.dump("db/raw", model.constantize)
    end
  end

  task load: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    ARGV.drop(1).each do |model|
      DataYaml.load("db/raw", model.constantize)
    end
  end

  task load_from_s3: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    subfolder = ARGV[1]
    fail "No subfolder given" if subfolder.nil?

    indir_url = "https://s3.eu-west-3.amazonaws.com/companydata-production/#{subfolder}"
    ARGV.drop(2).each do |model|
      DataYaml.load_from_s3(indir_url, model.constantize)
    end
  end

  task update: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    model = ARGV[1]
    source = ARGV[2]
    DataYaml.update_or_create(source, model.constantize)
  end
end
