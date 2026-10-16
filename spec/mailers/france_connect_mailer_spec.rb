require 'rails_helper'

RSpec.describe FranceConnectMailer do
  describe 'new_scopes' do
    let(:mail) { described_class.with(authorization_request:).new_scopes }

    let(:authorization_request) { create(:authorization_request, :api_droits_cnam, :validated) }

    it 'sends email to FC' do
      expect(mail.to).to eq(['support.partenaires@franceconnect.gouv.fr'])
    end

    it 'renders the body' do
      expect(decoded_text_body(mail)).to match('FranceConnect associée')
    end

    it 'says an authorization was delivered and identifies the FranceConnect request by its request number' do
      expect(decoded_text_body(mail)).to include('vient d’être délivrée', "demande FranceConnect associée : #{authorization_request.france_connect_authorization.request.formatted_id}")
    end

    context 'when the request has a stage' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :with_france_connect, :validated, modalities: %w[with_france_connect]) }

      it 'includes the stage in the body' do
        expect(decoded_text_body(mail)).to match('Bac à sable')
      end
    end

    it_behaves_like 'a mail whose html part mirrors its text part'
  end
end
