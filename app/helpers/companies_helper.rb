# frozen_string_literal: true

module CompaniesHelper
  def profile_attributes(company)
    attributes = []
    attributes << [t("companies.profile.legal_name"), company.name] if company.name.present?
    attributes << [t("companies.profile.legal_form"), company.legal_form] if company.legal_form.present?
    attributes << [t("companies.profile.category"), company.category] if company.category.present?
    attributes << [t("companies.profile.staff"), company.staff] if company.staff.present?
    attributes << [t("companies.profile.registration_1"), company.registration_1] if company.registration_1.present?
    attributes << [t("companies.profile.registration_2"), company.registration_2] if company.registration_2.present?
    attributes << [t("companies.profile.vat_number"), company.vat_number] if company.vat_number.present?
    attributes << [t("companies.profile.activity"), activity(company)] if activity(company)
    attributes
  end

  def founded(company)
    return t("companies.resume.founded", year: company.founded_at.year) if company.founded_at.present?
  end

  def linkedin_url(company)
    "https://www.linkedin.com/company/#{company.linkedin_id}/" if company.linkedin_id.present?
  end

  def google_maps_url(company)
    search_term = company.geolocation.presence || full_address_inline(company)
    "https://www.google.fr/maps/search/#{search_term}" if search_term.present?
  end

  def full_address(company)
    company.address_components.join("\n")
  end

  def full_address_inline(company)
    company.address_components.join(" ")
  end

  def activity(company)
    code = company.activity_code
    return nil if code.blank?
    "#{I18n.t("activity_codes.#{code}")} (#{code})"
  end
end
