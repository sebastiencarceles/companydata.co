# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "init_subscription" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.with(user_id: user.id).init_subscription }

    it "renders the headers" do
      expect(mail.subject).to eq("Votre abonnement a été initialisé")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["sebastien@companydata.co"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Pour vous laisser le temps")
    end
  end

  describe "no_subscription" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.with(user_id: user.id).no_subscription }

    it "renders the headers" do
      expect(mail.subject).to eq("Vous n'avez pas d'abonnement")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["sebastien@companydata.co"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Il semble que vous n'ayez pas d'abonnement actif")
    end
  end

  describe "missing_payment_method" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.with(user_id: user.id).missing_payment_method }

    it "renders the headers" do
      expect(mail.subject).to eq("Méthode de paiement manquante")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["sebastien@companydata.co"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Il semble que vous n'ayez pas d=C3=A9fini de m=C3=A9thode de paiement")
    end
  end

  describe "unpaid_invoices" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.with(user_id: user.id).unpaid_invoices }

    it "renders the headers" do
      expect(mail.subject).to eq("Factures impayées")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["sebastien@companydata.co"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Il semble que vous ayez des factures non r=C3=A9gl=C3=A9es")
    end
  end
end
