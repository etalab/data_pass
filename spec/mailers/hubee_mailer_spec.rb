require 'rails_helper'

RSpec.describe HubEEMailer, type: :mailer do
  describe '#administrateur_metier_cert_dc' do
    let(:mail) { described_class.with(authorization_request:).administrateur_metier_cert_dc }

    let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

    it 'renders the headers' do
      expect(mail.to).to eq([authorization_request.administrateur_metier_email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('HubEE')
    end
  end

  describe '#administrateur_metier_dila' do
    let(:mail) { described_class.with(authorization_request:).administrateur_metier_dila }

    let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

    it 'renders the headers' do
      expect(mail.to).to eq([authorization_request.administrateur_metier_email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('HubEE')
    end
  end
end
