# frozen_string_literal: true

namespace :vats do
  task create: :environment do
    Rails.logger.info "Create Vat for each company"
    companies = Company.where(country: "France").where.not(registration_1: [nil, ""]).left_outer_joins(:vat).where(vats: { id: nil })
    companies.find_each do |company|
      key = ((12 + 3 * (company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
      vat_number = "FR#{key}#{company.registration_1}"
      company.create_vat(
        vat_number: vat_number,
        status: :in_progress
      )
      Rails.logger.info "Vat number created for company #{company.id}: #{vat_number}"
    end
    Rails.logger.info "Done"
  end
end