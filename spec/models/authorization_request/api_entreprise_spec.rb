RSpec.describe AuthorizationRequest::APIEntreprise do
  describe '.contact_types' do
    it 'does not ask for a responsable de traitement anymore' do
      expect(described_class.contact_types).to eq(%i[delegue_protection_donnees contact_metier contact_technique])
    end
  end

  describe 'contacts validation' do
    subject(:authorization_request) { build(:authorization_request, :api_entreprise, :submitted, fill_all_attributes: true) }

    it 'is valid without any responsable de traitement' do
      expect(authorization_request).to be_valid
    end

    it 'still requires a délégué à la protection des données' do
      authorization_request.delegue_protection_donnees_email = nil

      expect(authorization_request).not_to be_valid
    end
  end

  describe 'existing responsable de traitement data' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    before do
      authorization_request.data['responsable_traitement_email'] = 'responsable@gouv.fr'
      authorization_request.save!
    end

    it 'keeps the data untouched in database' do
      expect(authorization_request.reload.data['responsable_traitement_email']).to eq('responsable@gouv.fr')
    end

    it 'no longer exposes it as a contact' do
      expect(authorization_request.reload.contacts.map(&:type)).not_to include(:responsable_traitement)
    end
  end
end
