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
  end
end
