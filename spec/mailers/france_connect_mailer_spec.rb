require 'rails_helper'

RSpec.describe FranceConnectMailer do
  describe 'new_scopes' do
    let(:mail) { described_class.with(authorization_request:).new_scopes }

    let(:authorization_request) { create(:authorization_request, :api_droits_cnam, :validated) }

    it 'sends email to FC' do
      expect(mail.to).to eq(['support.partenaires@franceconnect.gouv.fr'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('FranceConnect associée')
    end

    context 'when the request has a stage' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :with_france_connect, :validated, modalities: %w[with_france_connect]) }

      it 'includes the stage in the body' do
        expect(mail.body.encoded).to match('Bac à sable')
      end
    end
  end
end
