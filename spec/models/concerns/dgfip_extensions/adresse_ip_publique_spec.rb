RSpec.describe DGFIPExtensions::AdresseIpPublique do
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
        expect(klass.extra_attributes).to include(:adresse_ip_publique)
      end
    end

    it 'n’est pas déclaré sur les autres APIs DGFiP' do
      expect(AuthorizationRequest::APIOpaleSandbox.extra_attributes).not_to include(:adresse_ip_publique)
    end
  end

  describe 'validation de présence' do
    before { authorization_request.current_build_step = 'basic_infos' }

    it 'refuse une demande en saisie sans adresse IP' do
      authorization_request.adresse_ip_publique = nil

      expect(authorization_request).not_to be_valid
      expect(authorization_request.errors.full_messages.join).to include('Adresse IP publique')
    end

    it 'accepte une demande en saisie avec une adresse IP publique' do
      authorization_request.adresse_ip_publique = '192.0.2.10'

      expect(authorization_request).to be_valid
    end

    it 'refuse une adresse IP privée' do
      authorization_request.adresse_ip_publique = '10.0.0.1'

      expect(authorization_request).not_to be_valid
    end
  end

  describe 'à la soumission' do
    it 'exige l’adresse IP quelle que soit l’étape en cours' do
      authorization_request.adresse_ip_publique = nil

      expect(authorization_request.valid?(:submit)).to be(false)
    end

    it 'accepte la soumission une fois l’adresse renseignée' do
      authorization_request.adresse_ip_publique = '192.0.2.0/24'

      expect(authorization_request.errors[:adresse_ip_publique]).to be_empty
    end
  end

  describe 'stock existant' do
    it 'laisse valide une demande déjà validée sans adresse IP' do
      authorization_request.adresse_ip_publique = nil
      authorization_request.state = 'validated'
      authorization_request.last_validated_at = 1.month.ago

      expect(authorization_request).to be_valid
    end

    it 'laisse valide une demande archivée sans adresse IP' do
      authorization_request.adresse_ip_publique = nil
      authorization_request.state = 'archived'

      expect(authorization_request).to be_valid
    end
  end

  describe 'formulaire de production' do
    subject(:authorization_request) do
      build(:authorization_request, :api_ficoba_production, fill_all_attributes: true)
    end

    it 'hérite du bloc basic_infos sans le redemander' do
      expect(authorization_request.static_data_already_filled?(:basic_infos)).to be(true)
    end

    it 'porte tout de même l’attribut, pour afficher la valeur saisie en bac à sable' do
      expect(authorization_request).to respond_to(:adresse_ip_publique)
    end
  end
end
