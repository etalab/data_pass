RSpec.describe DGFIPExtensions::ExtraContactsInfos do
  subject(:authorization_request) do
    build(:authorization_request, :api_ficoba_sandbox, fill_all_attributes: true)
  end

  before { authorization_request.current_build_step = 'contacts' }

  it 'n’est pas déclaré hors DGFiP' do
    expect(AuthorizationRequest::APIEntreprise.extra_attributes).not_to include(:contact_technique_extra_email)
  end

  %i[contact_technique_extra_email extra_organization_contact_email].each do |attribute|
    describe attribute.to_s do
      it 'refuse une adresse email mal formée' do
        authorization_request.public_send(:"#{attribute}=", 'pas-une-adresse')

        expect(authorization_request).not_to be_valid
        expect(authorization_request.errors[attribute]).to be_present
      end

      it 'accepte une adresse email valide' do
        authorization_request.public_send(:"#{attribute}=", 'equipe@banque.fr')

        expect(authorization_request).to be_valid
      end

      it 'accepte un champ vide' do
        authorization_request.public_send(:"#{attribute}=", '')

        expect(authorization_request).to be_valid
      end

      it 'refuse une adresse email mal formée à la soumission' do
        authorization_request.public_send(:"#{attribute}=", 'pas-une-adresse')

        expect(authorization_request.valid?(:submit)).to be(false)
      end
    end
  end

  it 'ne bloque pas l’enregistrement d’une autre étape en cours de saisie' do
    authorization_request.current_build_step = 'basic_infos'
    authorization_request.contact_technique_extra_email = 'pas-une-adresse'

    expect(authorization_request).to be_valid
  end
end
