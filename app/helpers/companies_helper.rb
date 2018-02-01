# frozen_string_literal: true

module CompaniesHelper
  def profile_attributes(company)
    attributes = []
    attributes << ["Registered name", company.name] if company.name.present?
    attributes << ["Legal form", company.legal_form] if company.legal_form.present?
    attributes << ["Category", company.category] if company.category.present?
    attributes << ["Specialities", company.specialities] if company.specialities.present?
    attributes << ["Staff", company.staff] if company.staff.present?
    attributes << ["Registration #1", company.registration_1] if company.registration_1.present?
    attributes << ["Registration #2", company.registration_2] if company.registration_2.present?
    attributes << ["Activity", activity(company)] if activity(company)
  end

  def founded(company)
    return "Founded in #{company.founded_in}" if company.founded_in.present?
    return "Founded in #{company.founded_at.year}" if company.founded_at.present?
  end

  def linkedin_url(company)
    "https://www.linkedin.com/company/#{company.linkedin_id}/" if company.linkedin_id.present?
  end

  def google_maps_url(company)
    search_term = company.geolocation.presence || full_address_inline(company)
    "https://www.google.fr/maps/search/#{search_term}" if search_term.present?
  end

  def full_address(company)
    address_components(company).join("\n")
  end

  def full_address_inline(company)
    address_components(company).join(" ")
  end

  def activity(company)
    code = company.activity_code
    return nil if code.blank?
    "#{I18n.t("activity_codes.#{code}")} (#{code})"
  end

  private

    def address_components(company)
      [
        company.address_line_1,
        company.address_line_2,
        company.zipcode,
        company.city
      ].compact
    end
end
