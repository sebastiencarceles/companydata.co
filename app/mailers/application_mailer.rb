# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: "Sébastien de Companydata.co <sebastien@companydata.co>"
  layout "mailer"
end
