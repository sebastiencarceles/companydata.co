# frozen_string_literal: true

module CompaniesHelper
  def profile_labels_attributes
    [
      ["Type", :company_type],
      ["Category", :category],
      ["Specialities", :specialities],
      ["Staff", :staff],
      ["Registration number (part 1)", :registration_1],
      ["Registration number (part 2)", :registration_2],
      ["Activity code", :activity_code],
      ["Country", :country]
    ]
  end

  def founded(company)
    return "Founded in #{company.founded_in}" if company.founded_in.present?
    return "Founded in #{company.founded_at.year}" if company.founded_at.present?
  end

  def linkedin_url(company)
    "https://www.linkedin.com/company/#{company.linkedin_id}/" if company.linkedin_id.present?
  end
end
