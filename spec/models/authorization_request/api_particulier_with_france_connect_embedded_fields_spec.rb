RSpec.describe AuthorizationRequest::APIParticulier do
  let(:authorization_request) do
    build(:authorization_request, :api_particulier,
      modalities: ['france_connect'],
      fc_cadre_juridique_nature: 'CRPA Article L311-1',
      fc_cadre_juridique_url: 'https://legifrance.gouv.fr/legal',
      scopes: %w[openid family_name given_name birthdate birthplace birthcountry gender cnaf_quotient_familial],
      fc_alternative_connexion: '1',
      fc_eidas: 'eidas_1',
      contact_technique_family_name: 'Dupont',
      contact_technique_given_name: 'Jean',
      contact_technique_email: 'jean.dupont@gouv.fr',
      contact_technique_phone_number: '0612345678',
      contact_technique_job_title: 'Responsable technique')
  end

  describe '#france_connect_modality?' do
    context 'when france_connect is in modalities' do
      it 'returns true' do
        expect(authorization_request.france_connect_modality?).to be true
      end
    end

    context 'when france_connect is not in modalities' do
      let(:authorization_request) do
        build(:authorization_request, :api_particulier, modalities: ['params'])
      end

      it 'returns false' do
        expect(authorization_request.france_connect_modality?).to be false
      end
    end
  end

  describe 'validations' do
    context 'when france_connect modality is selected' do
      describe 'fc_cadre_juridique_nature' do
        it 'is required' do
          authorization_request.fc_cadre_juridique_nature = nil
          expect(authorization_request.validate(:submit)).to be false
          expect(authorization_request.errors[:fc_cadre_juridique_nature]).to be_present
        end

        it 'is valid with a value' do
          authorization_request.fc_cadre_juridique_nature = 'CRPA Article L311-1'
          authorization_request.validate(:submit)
          expect(authorization_request.errors[:fc_cadre_juridique_nature]).to be_empty
        end
      end

      describe 'fc_cadre_juridique_url or fc_cadre_juridique_document' do
        it 'requires at least one' do
          authorization_request.fc_cadre_juridique_url = nil
          expect(authorization_request.validate(:submit)).to be false
          expect(authorization_request.errors[:fc_cadre_juridique_url]).to be_present
        end

        it 'is valid with url' do
          authorization_request.fc_cadre_juridique_url = 'https://legifrance.gouv.fr/legal'
          authorization_request.validate(:submit)
          expect(authorization_request.errors[:fc_cadre_juridique_url]).to be_empty
        end

        it 'validates url format' do
          authorization_request.fc_cadre_juridique_url = 'invalid-url'
          expect(authorization_request.validate(:submit)).to be false
          expect(authorization_request.errors[:fc_cadre_juridique_url]).to be_present
        end
      end

      describe 'FranceConnect scopes validation' do
        it 'accepts when all FranceConnect scopes are present in scopes' do
          authorization_request.scopes = authorization_request.send(:france_connect_scope_values) + %w[cnaf_quotient_familial]
          authorization_request.validate(:submit)
          expect(authorization_request.errors[:scopes]).to be_empty
        end

        it 'rejects when some FranceConnect scopes are missing from scopes' do
          authorization_request.scopes = %w[family_name given_name cnaf_quotient_familial]
          expect(authorization_request.validate(:submit)).to be false
          expect(authorization_request.errors[:scopes]).to be_present
        end

        it 'rejects when no FranceConnect scopes in scopes' do
          authorization_request.scopes = %w[cnaf_quotient_familial]
          expect(authorization_request.validate(:submit)).to be false
          expect(authorization_request.errors[:scopes]).to be_present
        end

        it 'accepts extra non-FranceConnect scopes' do
          authorization_request.scopes = authorization_request.send(:france_connect_scope_values) + %w[cnaf_quotient_familial cnaf_allocataires]
          authorization_request.validate(:submit)
          expect(authorization_request.errors[:scopes]).to be_empty
        end
      end

      describe 'fc_alternative_connexion' do
        it 'is optional' do
          authorization_request.fc_alternative_connexion = false
          authorization_request.validate(:submit)
          expect(authorization_request.errors[:fc_alternative_connexion]).to be_empty
        end

        it 'can be true' do
          authorization_request.fc_alternative_connexion = true
          authorization_request.validate(:submit)
          expect(authorization_request.errors[:fc_alternative_connexion]).to be_empty
        end
      end

      describe 'contact_technique phone number' do
        it 'requires mobile phone number' do
          authorization_request.contact_technique_phone_number = '0612345678'
          authorization_request.validate(:submit)
          expect(authorization_request.errors[:contact_technique_phone_number]).to be_empty
        end

        it 'rejects landline phone numbers when FC modality is selected' do
          authorization_request.contact_technique_phone_number = '0145678901'
          expect(authorization_request.validate(:submit)).to be false
          expect(authorization_request.errors[:contact_technique_phone_number]).to be_present
        end
      end
    end

    context 'when france_connect modality is not selected' do
      let(:authorization_request) do
        build(:authorization_request, :api_particulier, :submitted,
          modalities: ['params'])
      end

      it 'does not require fc fields' do
        authorization_request.fc_cadre_juridique_nature = nil
        authorization_request.fc_cadre_juridique_url = nil
        authorization_request.scopes = %w[cnaf_quotient_familial]

        authorization_request.validate(:submit)
        expect(authorization_request.errors[:fc_cadre_juridique_nature]).to be_empty
        expect(authorization_request.errors[:fc_cadre_juridique_url]).to be_empty
        expect(authorization_request.errors[:scopes]).to be_empty
      end

      it 'accepts landline phone numbers for contact_technique' do
        authorization_request.contact_technique_phone_number = '0145678901'
        authorization_request.validate(:submit)
        expect(authorization_request.errors[:contact_technique_phone_number]).to be_empty
      end
    end
  end

  describe '#france_connect_attributes' do
    context 'when france_connect modality is selected' do
      it 'returns FC attributes' do
        attrs = authorization_request.france_connect_attributes

        expect(attrs[:cadre_juridique_nature]).to eq('CRPA Article L311-1')
        expect(attrs[:cadre_juridique_url]).to eq('https://legifrance.gouv.fr/legal')
        expect(attrs[:france_connect_eidas]).to eq('eidas_1')
        expect(attrs[:scopes]).to match_array(%w[openid family_name given_name birthdate birthplace birthcountry gender])
        expect(attrs[:alternative_connexion]).to eq '1'
      end

      it 'includes common attributes' do
        attrs = authorization_request.france_connect_attributes

        expect(attrs[:organization_id]).to eq(authorization_request.organization_id)
        expect(attrs[:applicant_id]).to eq(authorization_request.applicant_id)
        expect(attrs[:intitule]).to eq(authorization_request.intitule)
        expect(attrs[:description]).to eq(authorization_request.description)
      end

      it 'includes personal data attributes' do
        attrs = authorization_request.france_connect_attributes

        expect(attrs[:destinataire_donnees_caractere_personnel]).to eq(authorization_request.destinataire_donnees_caractere_personnel)
        expect(attrs[:duree_conservation_donnees_caractere_personnel]).to eq(authorization_request.duree_conservation_donnees_caractere_personnel)
        expect(attrs[:duree_conservation_donnees_caractere_personnel_justification]).to eq(authorization_request.duree_conservation_donnees_caractere_personnel_justification)
      end

      it 'includes basic infos attributes' do
        attrs = authorization_request.france_connect_attributes

        expect(attrs[:date_prevue_mise_en_production]).to eq(authorization_request.date_prevue_mise_en_production)
        expect(attrs[:volumetrie_approximative]).to eq(authorization_request.volumetrie_approximative)
      end

      it 'includes contact_technique attributes' do
        attrs = authorization_request.france_connect_attributes

        expect(attrs[:contact_technique_family_name]).to eq('Dupont')
        expect(attrs[:contact_technique_given_name]).to eq('Jean')
        expect(attrs[:contact_technique_email]).to eq('jean.dupont@gouv.fr')
        expect(attrs[:contact_technique_phone_number]).to eq('0612345678')
        expect(attrs[:contact_technique_job_title]).to eq('Responsable technique')
      end

      it 'includes responsable_traitement attributes mapped from contact_metier' do
        attrs = authorization_request.france_connect_attributes

        expect(attrs[:responsable_traitement_family_name]).to eq(authorization_request.contact_metier_family_name)
        expect(attrs[:responsable_traitement_given_name]).to eq(authorization_request.contact_metier_given_name)
        expect(attrs[:responsable_traitement_email]).to eq(authorization_request.contact_metier_email)
      end

      it 'includes delegue_protection_donnees attributes' do
        attrs = authorization_request.france_connect_attributes

        expect(attrs[:delegue_protection_donnees_family_name]).to eq(authorization_request.delegue_protection_donnees_family_name)
        expect(attrs[:delegue_protection_donnees_given_name]).to eq(authorization_request.delegue_protection_donnees_given_name)
        expect(attrs[:delegue_protection_donnees_email]).to eq(authorization_request.delegue_protection_donnees_email)
      end
    end

    context 'when france_connect modality is not selected' do
      let(:authorization_request) do
        build(:authorization_request, :api_particulier, modalities: ['params'])
      end

      it 'returns empty hash' do
        expect(authorization_request.france_connect_attributes).to eq({})
      end
    end
  end

  describe 'fc_scopes method' do
    it 'returns an array' do
      expect(authorization_request.fc_scopes).to be_a(Array)
    end

    it 'returns only FranceConnect scopes from scopes' do
      authorization_request.scopes = %w[cnaf_quotient_familial family_name given_name birthdate]
      expect(authorization_request.fc_scopes).to match_array(%w[family_name given_name birthdate])
    end

    it 'returns empty array when no scopes' do
      authorization_request.scopes = []
      expect(authorization_request.fc_scopes).to eq([])
    end

    it 'filters out non-FranceConnect scopes' do
      authorization_request.scopes = %w[cnaf_quotient_familial cnaf_allocataires]
      expect(authorization_request.fc_scopes).to eq([])
    end
  end

  describe 'fc_alternative_connexion checkbox' do
    it 'defaults to nil' do
      new_request = build(:authorization_request, :api_particulier, modalities: ['france_connect'])
      expect(new_request.fc_alternative_connexion).to be_nil
    end

    it 'can be set to 1' do
      authorization_request.fc_alternative_connexion = '1'
      expect(authorization_request.fc_alternative_connexion).to eq '1'
    end
  end

  describe '#available_scopes' do
    let(:authorization_request) { build(:authorization_request, :api_particulier_entrouvert_publik, modalities:) }
    let(:france_connect_scope_values) { %w[family_name given_name birthdate birthplace birthcountry gender openid] }

    context 'when france_connect modality is selected' do
      let(:modalities) { %w[france_connect] }

      it 'includes FranceConnect scopes' do
        fc_scopes = authorization_request.available_scopes.select { |s| s.group == 'FranceConnect' }
        expect(fc_scopes.map(&:value)).to match_array(france_connect_scope_values)
      end
    end

    context 'when france_connect modality is not selected' do
      let(:modalities) { %w[params] }

      it 'excludes FranceConnect scopes' do
        fc_scopes = authorization_request.available_scopes.select { |s| s.group == 'FranceConnect' }
        expect(fc_scopes).to be_empty
      end

      it 'still includes non-FranceConnect scopes' do
        non_fc_scopes = authorization_request.available_scopes.reject { |s| s.group == 'FranceConnect' }
        expect(non_fc_scopes).not_to be_empty
      end
    end
  end

  describe 'automatic removal of FranceConnect scopes' do
    let(:authorization_request) do
      create(
        :authorization_request,
        :api_particulier_entrouvert_publik,
        modalities: %w[france_connect],
        scopes: %w[cnaf_quotient_familial family_name given_name birthdate]
      )
    end

    it 'removes FranceConnect scopes when modality is deselected' do
      expect(authorization_request.scopes).to include('family_name', 'given_name', 'birthdate')

      authorization_request.modalities = %w[params]
      authorization_request.valid?

      expect(authorization_request.scopes).to include('cnaf_quotient_familial')
      expect(authorization_request.scopes).not_to include('family_name', 'given_name', 'birthdate')
    end

    it 'keeps FranceConnect scopes when modality remains selected' do
      authorization_request.modalities = %w[france_connect]
      authorization_request.valid?

      expect(authorization_request.scopes).to include('family_name', 'given_name', 'birthdate', 'cnaf_quotient_familial')
    end
  end

  describe '#attach_documents_to_france_connect_authorization' do
    let(:france_connect_authorization) { build(:authorization_request, :france_connect) }

    context 'when fc_cadre_juridique_document is attached' do
      before do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/dummy.pdf'), 'application/pdf')
        authorization_request.fc_cadre_juridique_document.attach(file)
      end

      it 'copies the document to the FranceConnect authorization' do
        expect(france_connect_authorization.cadre_juridique_document).not_to be_attached

        authorization_request.attach_documents_to_france_connect_authorization(france_connect_authorization)

        expect(france_connect_authorization.cadre_juridique_document).to be_attached
        expect(france_connect_authorization.cadre_juridique_document.count).to eq(1)
      end

      it 'uses the same blob' do
        authorization_request.attach_documents_to_france_connect_authorization(france_connect_authorization)

        expect(france_connect_authorization.cadre_juridique_document.first.blob).to eq(
          authorization_request.fc_cadre_juridique_document.first.blob
        )
      end
    end

    context 'when fc_cadre_juridique_document is not attached' do
      it 'does not attach anything' do
        expect(france_connect_authorization.cadre_juridique_document).not_to be_attached

        authorization_request.attach_documents_to_france_connect_authorization(france_connect_authorization)

        expect(france_connect_authorization.cadre_juridique_document).not_to be_attached
      end
    end
  end
end
