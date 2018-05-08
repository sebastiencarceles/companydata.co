# frozen_string_literal: true

namespace :vats do
  task create: :environment do
    Rails.logger.info "Create missing VATs"

    p = 1
    per_page = 10000
    while Company.page(p).per(per_page).any?
      Rails.logger.info "Create VATs for page #{p}"

      batch = []
      Company.page(p).per(per_page).each do |company|
        next if company.vat.present? || company.registration_1.nil? || company.country != "France"
        key = ((12 + 3 * (company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
        batch << Vat.new(company_id: company.id, country_code: "FR", status: "waiting_for_validation", value: "FR#{key}#{company.registration_1}")
      end
      Vat.import!(batch)

      p += 1
    end

    Rails.logger.info "Done"
  end

  task fetch: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    limit = ARGV[1].to_i

    scope = vats_to_fetch
    count = scope.count
    scope.limit(limit).each_with_index do |vat, index|
      vat.validate!
      Rails.logger.info "#{index}/#{count} - Fetched VAT for company #{vat.company_id}: #{vat.reload.status}"
    end
    Rails.logger.info "Done"
  end

  task remaining: :environment do
    Rails.logger.info "#{vats_to_fetch.count} remaining VATs to fetch"
  end

  task export: :environment do
    Rails.logger.info "Export VATs"

    scope = vats_to_fetch
    p = 1
    per_page = 55850
    while scope.page(p).per(per_page).count != 0
      CSV.open("tmp/vats-#{p.to_s.rjust(3, "0")}.csv", "w", headers: true) do |csv|
        csv << ["id", "value", "status"]
        scope.page(p).per(per_page).each do |vat|
          row = [vat.id, vat.value, vat.status]
          Rails.logger.info "Export #{row}"
          csv << row
        end
      end
      p += 1
    end

    Rails.logger.info "Done"
  end

  task import: :environment do
    Dir.glob("tmp/output-*.csv").sort.each do |source|
      Rails.logger.info "Import from #{source}"
      CSV.foreach(source, headers: true) do |row|
        id = row["id"]
        vat = Vat.find_by_id(id)
        fail "Unable to find VAT #{id}" unless vat

        if vat.status == "waiting_for_validation"
          Rails.logger.info "Update VAT #{id}: #{row["status"]}"
          vat.update!(status: row["status"], validated_at: DateTime.now)
        else
          Rails.logger.warn "Already fetched VAT #{id}: #{vat.status} (#{vat.validated_at})"
        end
      end
      File.delete(source)
    end

    Rails.logger.info "Done, remaining VATs to fetch: #{vats_to_fetch.count}"
  end

  task fix: :environment do
    Rails.logger.info "Populate VATs with missing values"

    Vat.where(value: nil, country_code: ["FR", "BE"]).find_each do |vat|
      vat.set_value
      vat.save
      Rails.logger.info "Set value for vat #{vat.id}: #{vat.reload.value}"
    end

    Rails.logger.info "Done"
  end

  private

    def vats_to_fetch
      Vat.where(status: "waiting_for_validation", country_code: ["FR", "BE"]).where.not(value: nil)
    end
end
