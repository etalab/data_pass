require 'rails_helper'

RSpec.describe ProduitsDinumMailer do
  describe '#transmit_convention' do
    subject(:mail) { described_class.with(authorization_request:).transmit_convention }

    let(:authorization_request) { create(:authorization_request, :produits_dinum, :validated) }

    it 'is sent to the contact référent des outils numériques' do
      expect(mail.to).to eq([authorization_request.contact_technique_email])
    end

    it 'links to the convention pdf' do
      expect(mail.body.encoded).to include('/conventions/convention_mise_a_disposition_produits_dinum.pdf')
    end

    it 'renders a subject with the request id' do
      expect(mail.subject).to include(authorization_request.formatted_id)
    end
  end
end
