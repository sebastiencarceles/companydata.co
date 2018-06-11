require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "init_subscription" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.with(user: user).init_subscription }

    it "renders the headers" do
      expect(mail.subject).to eq("Votre abonnement a été initialisé")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["sebastien@companydata.co"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Pour vous laisser le temps")
    end
  end
end
