RSpec.describe AuthorizationRequest::RegistreWallet do
  describe 'step « Les utilisations prévues »' do
    subject(:authorization_request) do
      build(:authorization_request, :registre_wallet, organization:, fill_all_attributes: true, wallet_privacy_policy_url: organization_policy)
    end

    let(:organization) { create(:organization) }
    let(:organization_policy) { 'https://velocite.example/confidentialite' }
    let(:today) { Date.new(2026, 11, 17) }
    let(:pid) { WalletRegistry::Rulebook.available.find_by!(identifier: 'pid') }
    let(:mdl) { WalletRegistry::Rulebook.available.find_by!(identifier: 'mdl') }

    let(:majority_attributes) do
      {
        name: 'Vérifier la majorité',
        purpose: 'Vérifier que vous avez plus de 18 ans avant de vous louer un vélo.',
        start_date: '2027-01-04'
      }
    end

    before do
      travel_to(today)
      authorization_request.wallet_intended_uses = []
    end

    def claim_ids(rulebook, *identifiers)
      rulebook.claims.where(identifier: identifiers).order(:position).ids
    end

    def add_use(attributes = {}, attestations = { pid => %w[family_name given_name birth_date] })
      use = authorization_request.wallet_intended_uses.build(majority_attributes.merge(attributes))
      attestations.each { |rulebook, identifiers| use.add_attestation(rulebook).selected_claim_ids = claim_ids(rulebook, *identifiers) }
      use
    end

    def validate_step
      authorization_request.current_build_step = 'wallet_intended_uses'
      authorization_request.validate
    end

    describe 'storage of a use (CA1)' do
      let!(:use) { add_use }

      it 'produces the TS5 Credentials, one per format of the PID' do
        expect(use.credentials).to eq(
          [
            {
              'format' => 'dc+sd-jwt',
              'meta' => { 'vct_values' => ['urn:eudi:pid:1'] },
              'claims' => [{ 'path' => ['family_name'] }, { 'path' => ['given_name'] }, { 'path' => ['birthdate'] }]
            },
            {
              'format' => 'mso_mdoc',
              'meta' => { 'doctype_value' => 'eu.europa.ec.eudi.pid.1' },
              'claims' => [
                { 'path' => %w[eu.europa.ec.eudi.pid.1 family_name] },
                { 'path' => %w[eu.europa.ec.eudi.pid.1 given_name] },
                { 'path' => %w[eu.europa.ec.eudi.pid.1 birth_date] }
              ]
            }
          ]
        )
      end

      it 'passes the step' do
        validate_step

        expect(authorization_request.errors).to be_empty
      end

      it 'stores rows that point to the rulebook and survive a reload' do
        authorization_request.save!

        stored = described_class.find(authorization_request.id).wallet_intended_uses.sole
        expect(stored).to have_attributes(name: 'Vérifier la majorité', start_date: Date.new(2027, 1, 4), claim_count: 3)
        expect(stored.attestations.map(&:rulebook)).to eq([pid])
        expect(authorization_request.data).not_to have_key('wallet_intended_uses')
      end
    end

    describe 'form of the step' do
      let!(:use) { add_use }

      before { authorization_request.save! }

      def submit(use_attributes)
        authorization_request.reload.assign_attributes(wallet_intended_uses_attributes: { '0' => use_attributes.merge(id: use.id) })
        authorization_request.save!(context: :save_within_wizard)
        authorization_request.reload.wallet_intended_uses.sole
      end

      it 'replaces the checked data of an attestation' do
        attestation = use.attestations.sole
        stored = submit(requested_attestations_attributes: { '0' => { id: attestation.id, selected_claim_ids: ['', *claim_ids(pid, 'portrait')] } })

        expect(stored.attestations.sole.selected_claims.map(&:identifier)).to eq(%w[portrait])
      end

      it 'leaves out data of another rulebook' do
        attestation = use.attestations.sole
        stored = submit(requested_attestations_attributes: { '0' => { id: attestation.id, selected_claim_ids: claim_ids(mdl, 'age_over_18') } })

        expect(stored.claim_count).to eq(0)
      end

      it 'cleans the name and the purpose' do
        stored = submit(name: ' <b>Vérifier</b> l’âge ', purpose: 'Vérifier l’âge &amp; rien d’autre.')

        expect([stored.name, stored.purpose]).to eq(['Vérifier l’âge', 'Vérifier l’âge & rien d’autre.'])
      end
    end

    describe 'certificates counter (CA2)' do
      it 'counts one registration certificate per use' do
        add_use
        add_use(name: 'Ouvrir un compte client')

        expect(authorization_request.wallet_registration_certificates_count).to eq(2)
      end

      it 'does not count a use about to be removed' do
        add_use.mark_for_destruction

        expect(authorization_request.wallet_registration_certificates_count).to eq(0)
      end
    end

    describe 'privacy policy of a use (CA5)' do
      it 'follows the policy of the organization while the applicant keeps it' do
        add_use(privacy_policy_url: organization_policy)
        authorization_request.save!
        authorization_request.update!(wallet_privacy_policy_url: 'https://velocite.example/nouvelle-politique')

        use = authorization_request.reload.wallet_intended_uses.sole
        expect(use.privacy_policy_url).to be_nil
        expect(use.effective_privacy_policy_url).to eq('https://velocite.example/nouvelle-politique')
      end

      it 'keeps the address typed for this use only' do
        add_use(privacy_policy_url: 'https://velocite.example/majorite')
        add_use(name: 'Autre')

        expect(authorization_request.wallet_intended_uses.map(&:effective_privacy_policy_url)).to eq(['https://velocite.example/majorite', organization_policy])
      end
    end

    describe 'validation of the step (CA3, CA4, CA6)' do
      def summary_errors
        authorization_request.errors.map { |error| [error.attribute, error.type] }
      end

      it 'requires at least one use' do
        validate_step

        expect(summary_errors).to eq([%i[wallet_intended_uses wallet_intended_uses_missing]])
      end

      it 'lists what is missing in an empty use, linked to its fields' do
        authorization_request.wallet_intended_uses.build
        validate_step

        expect(summary_errors).to contain_exactly(
          %i[wallet_intended_uses_attributes_0_name wallet_intended_use_name_blank],
          %i[wallet_intended_uses_attributes_0_purpose wallet_intended_use_purpose_blank],
          %i[wallet_intended_uses_attributes_0_attestations wallet_intended_use_attestations_blank],
          %i[wallet_intended_uses_attributes_0_start_date wallet_intended_use_start_date_blank]
        )
      end

      %w[--- ok .............................].each do |purpose|
        it "refuses the purpose « #{purpose} »" do
          use = add_use(purpose:)
          validate_step

          expect(summary_errors).to eq([%i[wallet_intended_uses_attributes_0_purpose wallet_intended_use_purpose_too_short]])
          expect(use.errors[:purpose]).to include(a_string_starting_with('Expliquez à l’usager'))
        end
      end

      it 'refuses a purpose of 301 characters, and tells its length' do
        use = add_use(purpose: 'a' * 301)
        validate_step

        expect(use.errors[:purpose]).to eq(['La finalité compte 301 caractères. Raccourcissez-la à 300 caractères au plus : l’usager la lit dans son wallet.'])
      end

      it 'accepts a purpose of 300 characters' do
        add_use(purpose: 'a' * 300)
        validate_step

        expect(authorization_request.errors).to be_empty
      end

      it 'refuses a privacy policy outside of https://' do
        add_use(privacy_policy_url: 'http://velocite.example')
        validate_step

        expect(summary_errors).to eq([%i[wallet_intended_uses_attributes_0_privacy_policy_url wallet_intended_use_privacy_policy_url_https_format]])
      end

      it 'refuses an attestation without checked data, and names it' do
        add_use({}, pid => %w[family_name], mdl => [])
        validate_step

        error = authorization_request.errors.first
        expect([error.attribute, error.type, error.options[:attestation_name]]).to eq([:"wallet_intended_uses_attributes_0_attestation_#{mdl.id}", :wallet_intended_use_attestations_no_claim, 'Permis de conduire mobile'])
      end

      it 'refuses a start date in the past, but accepts today' do
        add_use(start_date: '2026-11-16')
        add_use(start_date: '2026-11-17')
        validate_step

        expect(summary_errors).to eq([%i[wallet_intended_uses_attributes_0_start_date wallet_intended_use_start_date_past]])
      end

      it 'keeps accepting a recorded start date once it has passed' do
        add_use(start_date: '2026-11-17')
        authorization_request.save!
        travel_to(today + 5.days)

        authorization_request.reload.valid?(:submit)

        expect(authorization_request.errors.attribute_names).not_to include(:wallet_intended_uses_attributes_0_start_date)
      end

      it 'refuses a recorded start date moved to the past' do
        add_use(start_date: '2026-11-17')
        authorization_request.save!
        travel_to(today + 5.days)
        authorization_request.reload.wallet_intended_uses.to_a.first.start_date = '2026-11-20'

        authorization_request.valid?(:submit)

        expect(authorization_request.errors.attribute_names).to include(:wallet_intended_uses_attributes_0_start_date)
      end

      it 'refuses an end date before or on the start date' do
        add_use(end_date: '2027-01-04')
        validate_step

        expect(summary_errors).to eq([%i[wallet_intended_uses_attributes_0_end_date wallet_intended_use_end_date_before_start_date]])
      end

      it 'names the use in the summary message' do
        add_use(purpose: 'ok')
        validate_step

        expect(authorization_request.errors.first.options[:use_name]).to eq('Vérifier la majorité')
      end

      it 'ignores a use about to be removed' do
        add_use(purpose: 'ok').mark_for_destruction
        add_use
        validate_step

        expect(authorization_request.errors).to be_empty
      end
    end

    describe 'saving a draft within the wizard' do
      it 'accepts an incomplete use' do
        authorization_request.wallet_intended_uses.build(purpose: 'ok')

        expect(authorization_request.save(context: :save_within_wizard)).to be true
        expect(WalletRegistry::IntendedUse.where(authorization_request_id: authorization_request.id).count).to eq(1)
      end
    end

    describe 'attestations of a use' do
      let!(:use) { add_use }

      it 'adds an attestation once, without data' do
        2.times { use.add_attestation(mdl) }

        expect(use.attestations.map(&:rulebook)).to eq([pid, mdl])
        expect(use.claim_count).to eq(3)
      end

      it 'removes an attestation and its data' do
        use.remove_attestation(pid.id)

        expect(use.credentials).to be_empty
      end
    end
  end
end
