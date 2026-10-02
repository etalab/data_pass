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

    it 'no longer creates the legacy test accounts' do
      legacy_emails = %w[user@yopmail.com user11@yopmail.com user12@yopmail.com whatever@fia1.fr departement@yopmail.com api-entreprise@yopmail.com datapass@yopmail.com dgfip@yopmail.com]

      expect(User.where(email: legacy_emails)).to be_empty
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

  describe '#flushdb' do
    subject(:flushdb) { seeds.flushdb }

    it 'does not raise error' do
      expect {
        flushdb
      }.not_to raise_error
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
