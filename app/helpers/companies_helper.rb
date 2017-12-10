module CompaniesHelper
  def profile_labels_attributes
    [
      ["Type", :company_type],
      ["Category", :category],
      ["Specialities", :specialities],
      ["Registration number (part 1)", :registration_1],
      ["Registration number (part 2)", :registration_2],
      ["Activity code", :activity_code],
      ["Country", :country]
    ]
  end
end
