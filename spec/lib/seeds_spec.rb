RSpec.describe Seeds do
  let(:seeds) { described_class.new }

  describe '#perform' do
    before(:context) do
      seeds = described_class.new
      seeds.flushdb
      seeds.perform
    end

    after(:context) do
      described_class.new.flushdb
    end

    it 'verifies the contact emails of every seeded request' do
      contact_emails = AuthorizationRequest.all.flat_map { |request| request.class.contact_types.map { |contact_type| request.public_send(:"#{contact_type}_email") } }.compact_blank

      expect(contact_emails.uniq - VerifiedEmail.pluck(:email)).to be_empty
    end

    it 'exposes only perform, flushdb and create_data_providers' do
      expect(described_class.public_instance_methods(false)).to contain_exactly(:perform, :flushdb, :create_data_providers)
    end

    it 'gives the OAuth application to the API Entreprise developer' do
      expect(Doorkeeper::Application.find_by!(uid: 'client_id').owner.email).to eq('dev-apie@yopmail.com')
    end

    describe 'test accounts with roles only' do
      let(:expected_roles_by_email) do
        {
          'reporter-apie@yopmail.com' => %w[dinum:api_entreprise:reporter],
          'reporter-fd-menj@yopmail.com' => %w[menj:*:reporter],
          'instructeur-apie@yopmail.com' => %w[dinum:api_entreprise:instructor],
          'instructeur-dgfip@yopmail.com' => %w[dgfip:api_impot_particulier:instructor dgfip:api_impot_particulier_sandbox:instructor],
          'instructeur-multi-fd@yopmail.com' => %w[dinum:api_particulier:instructor cnam:api_droits_cnam:instructor],
          'instructeur-sans-perimetre@yopmail.com' => %w[mtes:api_gunenv:instructor],
          'manager-apie@yopmail.com' => %w[dinum:api_entreprise:manager],
          'manager-fd-dgfip@yopmail.com' => %w[dgfip:*:manager],
          'dev-apie@yopmail.com' => %w[dinum:api_entreprise:developer],
          'dev-apip@yopmail.com' => %w[dinum:api_particulier:developer],
          'dev-manager-dgfip@yopmail.com' => %w[dgfip:*:developer dgfip:*:manager],
          'admin@yopmail.com' => %w[admin],
          'interne-sans-droit@yopmail.com' => [],
        }
      end

      it 'creates each account with its exact roles' do
        roles_by_email = User.where(email: expected_roles_by_email.keys).to_h { |user| [user.email, user.roles] }

        expect(roles_by_email).to eq(expected_roles_by_email)
      end

      it 'gives admin-instructeur the admin role and every manager role' do
        admin_instructeur = User.find_by!(email: 'admin-instructeur@yopmail.com')

        expect(admin_instructeur.roles).to include('admin', 'dinum:api_entreprise:manager', 'dgfip:api_impot_particulier:manager')
      end

      it 'attaches every account to a verified organization' do
        emails = expected_roles_by_email.keys + ['admin-instructeur@yopmail.com']

        expect(emails.map { |email| User.find_by!(email:).current_organization_verified? }).to all(be(true))
      end

      it 'attaches provider accounts to their provider organization' do
        sirets_by_email = {
          'reporter-fd-menj@yopmail.com' => '11004301500012',
          'instructeur-dgfip@yopmail.com' => '13000495500014',
          'manager-fd-dgfip@yopmail.com' => '13000495500014',
          'dev-manager-dgfip@yopmail.com' => '13000495500014',
          'instructeur-sans-perimetre@yopmail.com' => '11006801200050',
          'instructeur-apie@yopmail.com' => '13002526500013',
        }

        expect(sirets_by_email.keys.index_with { |email| User.find_by!(email:).current_organization.siret }).to eq(sirets_by_email)
      end
    end

    describe 'reference applicant accounts' do
      it 'attaches each reference applicant to its verified organization' do
        sirets_by_email = {
          'dem-commune@yopmail.com' => '21920023500014',
          'dem-departement@yopmail.com' => '22690001700014',
          'dem-editeur@yopmail.com' => '32816124500027',
        }

        organizations = sirets_by_email.keys.index_with { |email| User.find_by!(email:).current_organization }

        expect(organizations.transform_values(&:siret)).to eq(sirets_by_email)
        expect(sirets_by_email.keys.map { |email| User.find_by!(email:).current_organization_verified? }).to all(be(true))
      end

      it 'gives reference applicants no role' do
        reference_applicants = User.where(email: %w[dem-commune@yopmail.com dem-departement@yopmail.com dem-editeur@yopmail.com])

        expect(reference_applicants.count).to eq(3)
        expect(reference_applicants.map(&:roles)).to all(be_empty)
      end
    end

    describe 'dem-commune scenarios' do
      let(:dem_commune) { User.find_by!(email: 'dem-commune@yopmail.com') }

      def scenario(intitule) = AuthorizationRequest.where(applicant: dem_commune).find { |request| request.try(:intitule) == intitule }

      it 'creates one request per lifecycle state' do
        states_by_intitule = {
          'Référence — Brouillon' => 'draft',
          'Référence — Soumise' => 'submitted',
          'Référence — Modifications demandées' => 'changes_requested',
          'Référence — Validée' => 'validated',
          'Référence — Refusée' => 'refused',
          'Référence — Révoquée' => 'revoked',
          'Référence — Archivée' => 'archived',
        }

        expect(states_by_intitule.keys.index_with { |intitule| scenario(intitule)&.state }).to eq(states_by_intitule)
      end

      it 'creates reopened requests, in draft and submitted' do
        expect(scenario('Référence — Réouverte')).to have_attributes(state: 'draft', reopening?: true)
        expect(scenario('Référence — Réouverte et soumise')).to have_attributes(state: 'submitted', reopening?: true)
      end

      it 'creates a request migrated from v1' do
        expect(scenario('Référence — Migration v1')).to have_attributes(dirty_from_v1: true)
      end

      it 'creates a request with unread messages for instructors' do
        expect(scenario('Référence — Messages non lus').messages).to be_present
      end

      it 'creates a request with an external business contact' do
        expect(scenario('Référence — Contact métier externe').contact_metier_email).to eq('dem-departement@yopmail.com')
      end

      it 'creates a submitted request with an attached document' do
        attached_document_request = scenario('Référence — Pièce jointe')

        expect(attached_document_request.cadre_juridique_document).to be_attached
        expect(attached_document_request.state).to eq('submitted')
      end

      it 'creates a request whose next stage is in progress' do
        expect(scenario('Référence — Palier 2 en cours')).to have_attributes(type: 'AuthorizationRequest::APIImpotParticulier', state: 'draft')
      end

      it 'creates a request linked to a FranceConnect authorization' do
        france_connect_authorization = scenario('Référence — FranceConnect').latest_authorization

        expect(scenario('Référence — API Impôt particulier liée à FranceConnect').france_connect_authorization_id).to eq(france_connect_authorization.id.to_s)
      end

      it 'gives a fixed id to each reference request' do
        ids_by_intitule = {
          'Référence — Brouillon' => 1,
          'Référence — Soumise' => 2,
          'Référence — Modifications demandées' => 3,
          'Référence — Validée' => 4,
          'Référence — Refusée' => 5,
          'Référence — Révoquée' => 6,
          'Référence — Archivée' => 7,
          'Référence — Réouverte' => 8,
          'Référence — Réouverte et soumise' => 9,
          'Référence — Migration v1' => 10,
          'Référence — Messages non lus' => 11,
          'Référence — Contact métier externe' => 12,
          'Référence — Pièce jointe' => 13,
          'Référence — Palier 2 en cours' => 14,
          'Référence — FranceConnect' => 15,
          'Référence — API Impôt particulier liée à FranceConnect' => 16,
        }

        expect(ids_by_intitule.keys.index_with { |intitule| scenario(intitule)&.id }).to eq(ids_by_intitule)
      end

      it 'numbers the requests created afterwards above the reference ids' do
        expect(create(:authorization_request).id).to be > 16
      end

      it 'gives dem-commune only the reference requests' do
        expect(AuthorizationRequest.where(applicant: dem_commune).order(:id).pluck(:id)).to eq((1..16).to_a)
      end

      it 'mentions dem-commune as a business contact on no other request' do
        expect(AuthorizationRequest.where.not(applicant: dem_commune).select { |request| request.try(:contact_metier_email) == dem_commune.email }).to be_empty
      end

      it 'creates a draft request prepared by an instructor' do
        expect(InstructorDraftRequest.where(applicant: dem_commune).map { |draft| draft.data['intitule'] }).to include('Référence — Brouillon d’instructeur')
      end
    end

    it 'gives the historical requests to dem-historique' do
      historical_applicant = User.find_by!(email: 'dem-historique@yopmail.com')
      intitules = AuthorizationRequest.where(applicant: historical_applicant).map { |request| request.try(:intitule) }

      expect(intitules).to include('Portail des appels d’offres', 'Portail famille avec FranceConnect unifié', 'Habilitation mise à jour')
      expect(AuthorizationRequest.where(applicant: historical_applicant).pluck(:type)).to include('AuthorizationRequest::APIImpotParticulier', 'AuthorizationRequest::HubEECertDC')
    end

    describe 'applicant accounts in a particular state' do
      def user(email) = User.find_by!(email:)

      it 'creates an applicant whose organization link is not verified' do
        expect(user('dem-org-non-verifiee@yopmail.com').current_organization_verified?).to be(false)
      end

      it 'creates an applicant with a verified current organization and an unverified one' do
        multi_orga = user('dem-multi-orga@yopmail.com')

        expect(multi_orga.organizations_users.map(&:verified)).to contain_exactly(true, false)
        expect(multi_orga.current_organization_verified?).to be(true)
      end

      it 'creates an applicant whose organization is closed' do
        expect(user('dem-orga-fermee@yopmail.com').current_organization).to be_closed
      end

      it 'creates an applicant without any organization' do
        expect(user('dem-vierge@yopmail.com').organizations).to be_empty
      end

      it 'creates a banned applicant' do
        expect(user('dem-banni@yopmail.com')).to be_banned
      end

      it 'creates an applicant whose email is undeliverable' do
        expect(VerifiedEmail.find_by!(email: 'dem-email-ko@yopmail.com')).to be_unreachable
      end
    end

    describe 'instruction events' do
      let(:instruction_events) do
        AuthorizationRequestEvent.where(name: %w[approve refuse request_changes revoke]).includes(:user, :authorization_request)
      end

      def instructed_type(event) = event.authorization_request.type.underscore.split('/').last

      it 'are all performed by an instructor of the instructed type' do
        unauthorized_events = instruction_events.reject { |event| event.user.instructor?(instructed_type(event)) }

        expect(unauthorized_events.map { |event| [event.user.email, instructed_type(event)] }).to be_empty
      end

      it 'are never performed by the legacy API Entreprise instructor' do
        expect(instruction_events.map { |event| event.user.email }).not_to include('api-entreprise@yopmail.com')
      end

      it 'are performed by instructeur-apie for API Entreprise requests' do
        api_entreprise_events = instruction_events.select { |event| instructed_type(event) == 'api_entreprise' }

        expect(api_entreprise_events.map { |event| event.user.email }.uniq).to eq(['instructeur-apie@yopmail.com'])
      end
    end

    describe 'test account identities' do
      let(:blank_applicant_email) { 'dem-vierge@yopmail.com' }
      let(:test_accounts) { User.where(email: Seeds::TestAccounts::PROFILES.keys) }

      it 'gives every test account a full name, a job title and a fictional phone number' do
        expect(test_accounts.count).to eq(Seeds::TestAccounts::PROFILES.size)
        expect(test_accounts.map { |user| user.full_name == user.email }).to all(be(false))
        expect(test_accounts.map(&:job_title)).to all(be_present)
        expect(test_accounts.map(&:phone_number)).to all(start_with('019900'))
      end

      it 'leaves the blank applicant without any identity' do
        blank_applicant = User.find_by!(email: blank_applicant_email)

        expect(blank_applicant.full_name).to eq(blank_applicant_email)
      end
    end
  end

  describe '#create_data_providers' do
    it 'creates the data providers on an empty database, as the migration and cucumber do' do
      seeds.create_data_providers

      expect(DataProvider.pluck(:slug)).to include('dinum', 'dgfip', 'menj')
    end
  end

  describe '#flushdb' do
    subject(:flushdb) { seeds.flushdb }

    it 'does not raise error' do
      expect {
        flushdb
      }.not_to raise_error
    end

    it 'restarts the ids from 1' do
      create(:authorization_request)

      flushdb

      expect(create(:authorization_request).id).to eq(1)
    end

    it 'resets the unread messages counters along with the ids' do
      create(:authorization_request).redis_unread_messages_from_applicant.increment

      flushdb

      expect(create(:authorization_request).unread_messages_from_applicant_count).to eq(0)
    end

    context 'when in production' do
      before do
        allow(Rails).to receive(:env).and_return('production')
      end

      it 'raises error' do
        expect {
          flushdb
        }.to raise_error(StandardError)
      end
    end
  end
end
