# frozen_string_literal: true

module CompaniesHelper
  def profile_labels_attributes
    [
      ["Registered name", :name],
      ["Legal form", :legal_form],
      ["Category", :category],
      ["Specialities", :specialities],
      ["Staff", :staff],
      ["Registration #1", :registration_1],
      ["Registration #2", :registration_2],
      ["Activity code", :activity_code]
    ]
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
