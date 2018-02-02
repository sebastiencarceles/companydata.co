# frozen_string_literal: true

namespace :migrations do
  task smooth_names: :environment do
    Company.where(smooth_name: nil).find_each do |company|
      company.update_columns(smooth_name: company.name.gsub("*", " ").gsub("/", " ").titleize.strip)
    end
  end
end
