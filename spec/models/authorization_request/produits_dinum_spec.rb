RSpec.describe AuthorizationRequest::ProduitsDinum do
  describe 'contact attributes exclusion' do
    let(:authorization_request) { build(:authorization_request, :produits_dinum) }

    before do
      allow(authorization_request).to receive(:need_complete_validation?) { |key| key == :contacts }

      %i[contact_technique delegue_protection_donnees responsable_traitement].each do |contact_type|
        authorization_request.public_send(:"#{contact_type}_family_name=", 'Dupont')
        authorization_request.public_send(:"#{contact_type}_given_name=", 'Jean')
        authorization_request.public_send(:"#{contact_type}_email=", 'jean.dupont@gouv.fr')
      end
    end

    it 'does not require phone_number nor job_title on any contact' do
      authorization_request.valid?

      %i[contact_technique delegue_protection_donnees responsable_traitement].each do |contact_type|
        expect(authorization_request.errors[:"#{contact_type}_phone_number"]).to be_empty
        expect(authorization_request.errors[:"#{contact_type}_job_title"]).to be_empty
      end
    end

    it 'still requires email on contacts' do
      authorization_request.contact_technique_email = nil
      authorization_request.valid?

      expect(authorization_request.errors[:contact_technique_email]).not_to be_empty
    end
  end
end
