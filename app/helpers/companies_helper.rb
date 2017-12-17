# frozen_string_literal: true

module CompaniesHelper
  def profile_labels_attributes
    [
      ["Legal form", :legal_form],
      ["Category", :category],
      ["Specialities", :specialities],
      ["Staff", :staff],
      ["Registration number (part 1)", :registration_1],
      ["Registration number (part 2)", :registration_2],
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

  def full_address(company)
    [
      company.address_line_1,
      company.address_line_2,
      company.zipcode,
      company.city
    ].compact.join("\n")
  end
end
