require 'rails_helper'

RSpec.describe HubEEMailer do
  describe '#administrateur_metier' do
    context 'with cert_dc' do
      let(:mail) { described_class.with(authorization_request:).administrateur_metier(:cert_dc) }

      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

      it 'renders the headers' do
        expect(mail.to).to eq([authorization_request.administrateur_metier_email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match('HubEE')
      end
    end

    context 'with dila' do
      let(:mail) { described_class.with(authorization_request:).administrateur_metier(:dila) }

      let(:authorization_request) { create(:authorization_request, :hubee_dila, :validated) }

      it 'renders the headers' do
        expect(mail.to).to eq([authorization_request.administrateur_metier_email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match('HubEE')
      end
    end
  end
end
