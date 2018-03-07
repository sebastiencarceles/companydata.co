# frozen_string_literal: true

module ApplicationHelper
  def app_name
    "Companydata.co"
  end

  def contact_email
    "sebastien@companydata.co"
  end

  def docs_url(sub_path = nil)
    "http://sebastiencarceles.github.io/companydata-api-docs#{sub_path}"
  end
end
