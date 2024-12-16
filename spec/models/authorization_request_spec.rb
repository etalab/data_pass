RSpec.describe AuthorizationRequest do
  describe 'factories' do
    it 'has valid factories for all states and all form_uids' do
      AuthorizationRequestForm.all.each do |form|
        # rubocop:disable Performance/CollectionLiteralInLoop
        %w[draft validated].each do |state_name|
          # rubocop:enable Performance/CollectionLiteralInLoop
          expect(build(:authorization_request, form.uid.underscore, state_name)).to be_valid
        rescue ActiveRecord::RecordNotFound
          fail "Factory not found for form_uid: #{form.uid.underscore} and state: #{state_name}"
        end
      end
    end

    it 'saves the authorization request with state submitted and then changes it to draft' do
      authorization_request = build(:authorization_request, :api_entreprise, state: 'submitted')
      authorization_request.save!
      authorization_request.state = 'draft'
      authorization_request.save!

      expect(authorization_request.state).to eq('draft')
    end

    it 'has a valid reopened factory' do
      authorization_request = create(:authorization_request, :api_entreprise, :reopened)

      expect(authorization_request).to be_reopening
    end

    it 'has a valid reopened and submitted factory' do
      authorization_request = create(:authorization_request, :api_entreprise, :reopened_and_submitted)

      expect(authorization_request).to be_reopening
      expect(authorization_request.state).to eq('submitted')
    end

    it 'has a validated factory which creates an authorization' do
      authorization_request = create(:authorization_request, :api_entreprise, :validated)

      expect(authorization_request).to be_validated
      expect(authorization_request.latest_authorization).to be_a(Authorization)
    end

    describe 'with an authorization definition which has a previous stage, in whatever stage' do
      it 'creates an authorization to one of the previous stage' do
        authorization_request = create(:authorization_request, :api_impot_particulier_production, :draft)

        expect(authorization_request.latest_authorization.authorization_request_class).to eq('AuthorizationRequest::APIImpotParticulierSandbox')
      end
    end
  end

  describe '#access_link' do
    subject { authorization_request.access_link }

    let(:authorization_request) { create(:authorization_request, definition_key, external_provider_id:) }
    let(:external_provider_id) { 'some_token' }

    context 'with a simple access link' do
      let(:definition_key) { :hubee_cert_dc }

      it { is_expected.to eq 'https://portail.hubee.numerique.gouv.fr' }

      context 'with an empty external_provider_id' do
        let(:external_provider_id) { nil }

        it { is_expected.to be_nil }
      end
    end

    context 'with an interpolated access link' do
      let(:definition_key) { :api_entreprise }

      it { is_expected.to eq 'https://entreprise.api.gouv.fr/compte/jetons/some_token' }

      context 'with an empty external_provider_id' do
        let(:external_provider_id) { nil }

        it { is_expected.to be_nil }
      end
    end

    context 'with an empty access link' do
      let(:definition_key) { :api_service_national }

      it { is_expected.to be_nil }
    end
  end

  describe 'strip on attributes' do
    subject(:authorization_request) { build(:authorization_request, :api_entreprise, intitule: "  #{valid_intitule} ", contact_technique_email: "  #{valid_contact_technique_email}") }

    let(:valid_intitule) { 'valid intitule' }
    let(:valid_contact_technique_email) { 'tech@gouv.fr' }

    it 'strips attributes on save' do
      authorization_request.save!

      expect(authorization_request.intitule).to eq(valid_intitule)
      expect(authorization_request.contact_technique_email).to eq(valid_contact_technique_email)
    end
  end

  describe 'destroy' do
    subject(:destroy) { authorization_request.destroy }

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it 'does not raise error due to db constraints' do
      expect { destroy }.not_to raise_error
    end
  end

  describe '#contact_types_for' do
    subject { authorization_request.contact_types_for(user) }

    let(:user) { create(:user) }
    let(:authorization_request) { create(:authorization_request, data: { 'contact_test_email' => contact_email, 'contact_lol_email' => contact_email, 'whatever' => user.email }) }

    context 'when user is a valid contact' do
      let(:contact_email) { user.email }

      it { is_expected.to eq(%w[contact_test contact_lol]) }
    end

    context 'when user is not a valid contact' do
      let(:contact_email) { 'what@ever.fr' }

      it { is_expected.to eq([]) }
    end
  end

  describe 'archive event' do
    subject(:archive) { authorization_request.archive }

    let(:authorization_request) { create(:authorization_request, :api_entreprise, state: 'draft') }

    it 'archives the authorization request' do
      expect {
        archive
      }.to change { authorization_request.reload.state }.from('draft').to('archived')
    end
  end

  describe 'save context' do
    subject(:save_authorization_request) { authorization_request.save(context:) }

    context 'when context is not provided' do
      let(:context) { nil }

      context 'when authorization request is not entire filled' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise) }

        it { is_expected.to be_truthy }
      end
    end

    context 'when context is `review`' do
      let(:context) { :review }

      context 'when authorization request is not entire filled' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise) }

        it { is_expected.to be_falsey }
      end

      context 'when authorization request is entire filled without terms' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise, fill_all_attributes: true) }

        before do
          authorization_request.update!(terms_of_service_accepted: false)
        end

        it { is_expected.to be_truthy }
      end
    end

    context 'when context is `submit`' do
      let(:context) { :submit }

      context 'when authorization request is not entire filled' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise) }

        it { is_expected.to be_falsey }
      end

      context 'when authorization request is entire filled without terms' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise, fill_all_attributes: true) }

        before do
          authorization_request.update!(terms_of_service_accepted: false)
        end

        it { is_expected.to be_falsey }
      end

      context 'when authorization request is entire filled with terms' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise, fill_all_attributes: true) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe 'contact email validation' do
    subject(:authorization_request) { build(:authorization_request, :api_entreprise, fill_all_attributes: true, contact_metier_email: email) }

    let(:email) { generate(:email) }
    let!(:verified_email) { create(:verified_email, email:, status: 'undeliverable', verified_at: 1.day.ago) }

    describe 'without validation context' do
      it { is_expected.to be_valid }
    end

    describe 'with submit validation context' do
      it { is_expected.not_to be_valid(:submit) }
    end
  end

  describe 'unicity of authorization request validation' do
    subject(:authorization_request) { build(:authorization_request, :hubee_cert_dc, organization:) }

    let(:organization) { create(:organization) }

    context 'when an authorization request already exists for the same organization' do
      before do
        create(:authorization_request, :hubee_cert_dc, organization:)
      end

      it { is_expected.not_to be_valid }
    end

    context 'when an authorization request already exists for the same organization but is archived' do
      before do
        create(:authorization_request, :hubee_cert_dc, :archived, organization:)
      end

      it { is_expected.to be_valid }
    end

    context 'when there is no authorization request for the same organization' do
      it { is_expected.to be_valid }
    end
  end

  describe 'copy behaviour' do
    subject!(:authorization_request_copy) do
      create(:authorization_request, :api_entreprise, copied_from_request: authorization_request)
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it { expect(authorization_request_copy.copied_from_request).to eq(authorization_request) }
    it { expect(authorization_request.next_request_copied).to eq(authorization_request_copy) }
  end

  describe '#legacy_scope_values' do
    subject { authorization_request.legacy_scope_values }

    context 'when authorization has scopes not referenced within the definition' do
      let(:authorization_request) do
        authorization_request = create(:authorization_request, :api_entreprise)
        authorization_request.data['scopes'] = %w[old_scope1 old_scope2 unites_legales_etablissements_insee]
        authorization_request.save!
        authorization_request
      end

      it { is_expected.to eq(%w[old_scope1 old_scope2]) }
    end
  end

  describe 'scopes config behaviour' do
    describe '#available_scopes' do
      subject(:available_scopes) { authorization_request.available_scopes }

      context 'without config' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise) }

        it { expect(available_scopes.map(&:value)).to match_array(authorization_request.definition.scopes.map(&:value)) }
      end

      context 'with displayed config on form' do
        let(:authorization_request) { create(:authorization_request, :api_particulier_abelium) }

        it { expect(available_scopes.map(&:value)).to match_array(%w[cnaf_quotient_familial cnaf_allocataires cnaf_enfants cnaf_adresse]) }
      end
    end

    describe '#disabled_scopes' do
      subject(:disabled_scopes) { authorization_request.disabled_scopes }

      context 'without config' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise) }

        it { is_expected.to be_empty }
      end

      context 'with disabled scopes config on form' do
        let(:authorization_request) { create(:authorization_request, :api_particulier_abelium) }

        it { expect(disabled_scopes.map(&:value)).to contain_exactly('cnaf_quotient_familial') }
      end
    end
  end

  describe 'cadre_juridique_url validation' do
    subject(:authorization_request) do
      authorization_request = create(:authorization_request, :api_entreprise, :changes_requested)
      authorization_request.cadre_juridique_url = url
      authorization_request
    end

    context 'with a valid url' do
      let(:url) { 'https://example.com' }

      it { is_expected.to be_valid(:submit) }
    end

    context 'with a valid url without schema' do
      let(:url) { 'www.example.com' }

      it { is_expected.to be_valid(:submit) }
    end

    context 'with an invalid url' do
      let(:url) { 'invalid_url' }

      it { is_expected.not_to be_valid(:submit) }
    end
  end

  describe '#bulk_updates' do
    subject(:bulk_updates) { authorization_request.bulk_updates }

    let(:authorization_request) { create(:authorization_request, :api_entreprise, created_at: 1.week.ago) }

    let!(:invalid_bulk_update_different_uid) { create(:bulk_authorization_request_update, authorization_definition_uid: 'api_particulier') }
    let!(:invalid_bulk_update_old_date) { create(:bulk_authorization_request_update, authorization_definition_uid: 'api_entreprise', application_date: 2.weeks.ago.to_date) }
    let!(:valid_bulk_update) { create(:bulk_authorization_request_update, authorization_definition_uid: 'api_entreprise', application_date: 2.days.ago.to_date) }

    it { is_expected.to contain_exactly(valid_bulk_update) }
  end

  describe '.with_scopes_intersecting' do
    subject { AuthorizationRequest::HubEEDila.with_scopes_intersecting(scopes) }

    let(:scopes) { %w[etat_civil depot_dossier_pacs] }

    let!(:valid_authorization_request_with_one_scope) { create(:authorization_request, :hubee_dila, scopes: %w[etat_civil]) }
    let!(:valid_authorization_request_with_more_scopes) { create(:authorization_request, :hubee_dila, scopes: %w[etat_civil depot_dossier_pacs je_change_de_coordonnees]) }
    let!(:invalid_authorization_request) { create(:authorization_request, :hubee_dila, scopes: %w[je_change_de_coordonnees]) }

    it { is_expected.to contain_exactly(valid_authorization_request_with_one_scope, valid_authorization_request_with_more_scopes) }
  end
end
