# frozen_string_literal: true

namespace :migrations do
  task smooth_names: :environment do
    Company.where(smooth_name: nil).find_each do |company|
      company.update!(smooth_name: company.name.gsub("*", " ").gsub("/", " ").titleize.strip)
      Rails.logger.info "Computed smooth name for #{company.name}: #{company.smooth_name}"
    end
  end
end
