RSpec.describe DGFIPExtensions::AdressePostaleContactTechnique do
  subject(:authorization_request) do
    build(:authorization_request, :api_ficoba_sandbox, fill_all_attributes: true)
  end

  describe 'périmètre' do
    it 'est déclaré sur les APIs DGFiP prioritaires' do
      [
        AuthorizationRequest::APISFiP,
        AuthorizationRequest::APISFiPSandbox,
        AuthorizationRequest::APISFiPR2P,
        AuthorizationRequest::APISFiPR2PSandbox,
        AuthorizationRequest::APIImpotParticulier,
        AuthorizationRequest::APIImpotParticulierSandbox,
        AuthorizationRequest::APIRial,
        AuthorizationRequest::APIRialSandbox,
        AuthorizationRequest::APIINFINOE,
        AuthorizationRequest::APIINFINOESandbox,
        AuthorizationRequest::APIFicoba,
        AuthorizationRequest::APIFicobaSandbox,
      ].each do |klass|
        expect(klass.extra_attributes).to include(:contact_technique_adresse, :contact_technique_adresse_complement)
      end
    end

    it 'n’est pas déclaré sur les autres APIs DGFiP' do
      expect(AuthorizationRequest::APIOpaleSandbox.extra_attributes).not_to include(:contact_technique_adresse)
    end
  end

  describe 'validation de présence' do
    before { authorization_request.current_build_step = 'contacts' }

    it 'refuse une demande en saisie sans adresse du contact technique' do
      authorization_request.contact_technique_adresse = nil

      expect(authorization_request).not_to be_valid
      expect(authorization_request.errors.full_messages.join).to include('Adresse du contact technique')
    end

    it 'accepte une demande en saisie avec l’adresse renseignée' do
      authorization_request.contact_technique_adresse = '10 rue de la Paix, 75002 Paris'

      expect(authorization_request).to be_valid
    end

    it 'n’exige jamais le complément d’adresse' do
      authorization_request.contact_technique_adresse = '10 rue de la Paix, 75002 Paris'
      authorization_request.contact_technique_adresse_complement = nil

      expect(authorization_request).to be_valid
    end
  end

  describe 'à la soumission' do
    it 'exige l’adresse quelle que soit l’étape en cours' do
      authorization_request.contact_technique_adresse = nil

      expect(authorization_request.valid?(:submit)).to be(false)
    end
  end

  describe 'enregistrement d’un bloc depuis la synthèse' do
    it 'n’exige pas l’adresse, pour débloquer les demandes créées avant son ajout' do
      authorization_request.state = 'changes_requested'
      authorization_request.contact_technique_adresse = nil

      expect(authorization_request.valid?(:review)).to be(true)
    end
  end

  describe 'stock existant' do
    it 'laisse valide une demande déjà validée sans adresse' do
      authorization_request.contact_technique_adresse = nil
      authorization_request.state = 'validated'
      authorization_request.last_validated_at = 1.month.ago

      expect(authorization_request).to be_valid
    end
  end

  describe 'formulaire de production' do
    subject(:authorization_request) do
      build(:authorization_request, :api_ficoba_production, fill_all_attributes: true)
    end

    it 'hérite du bloc contacts sans le redemander' do
      expect(authorization_request.static_data_already_filled?(:contacts)).to be(true)
    end

    it 'porte tout de même l’attribut, pour afficher la valeur saisie en bac à sable' do
      expect(authorization_request).to respond_to(:contact_technique_adresse)
    end
  end
end
