RSpec.describe Admin::GrantAPIAccess do
  subject(:organizer) { described_class.call(admin:, params:) }

  let(:admin) { create(:user, :admin) }
  let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner:, scopes: 'public read_authorizations') }
  let(:data_provider) do
    slug = AuthorizationDefinition.find('api_entreprise').provider_slug
    DataProvider.find_by(slug:) || create(:data_provider, slug:)
  end
  let(:params) do
    {
      oauth_application_id: application.id,
      data_provider_id: data_provider.id,
      action: 'submission',
      grant_reason: 'Parcours qualifié le 12/10',
    }
  end

  it 'creates an active grant traced with the admin and the reason' do
    expect { organizer }.to change(APIAccessGrant.active, :count).by(1)

    expect(organizer.grant).to have_attributes(
      granted_by_email: admin.email,
      grant_reason: 'Parcours qualifié le 12/10',
      oauth_application_name: application.name
    )
    expect(organizer.grant.granted_at).to be_present
  end

  it 'adds the matching scope to the application' do
    organizer

    expect(application.reload.scopes.to_a).to match_array(%w[public read_authorizations submit_authorizations])
  end

  it 'drops scopes that are no longer configured instead of failing' do
    application.update_column(:scopes, 'public read_authorizations old_submit_scope')

    expect(organizer).to be_a_success
    expect(application.reload.scopes.to_a).to match_array(%w[public read_authorizations submit_authorizations])
  end

  context 'when the application has no explicit scopes' do
    before { application.update_column(:scopes, '') }

    it 'starts from the Doorkeeper default scopes' do
      organizer

      expect(application.reload.scopes.to_s).to eq('public read_authorizations submit_authorizations')
    end
  end

  context 'when the reason is blank' do
    let(:params) { super().merge(grant_reason: '') }

    it 'fails and leaves the application scopes untouched' do
      expect(organizer).to be_a_failure
      expect(application.reload.scopes.to_a).to match_array(%w[public read_authorizations])
    end
  end

  context 'when the same right is already active' do
    before { described_class.call(admin:, params:) }

    it 'fails without raising' do
      expect(organizer).to be_a_failure
    end
  end

  context 'when the database unique index rejects a duplicate that passed validation' do
    before do
      described_class.call(admin:, params:)
      allow(APIAccessGrant).to receive(:new).and_wrap_original do |original, *args|
        original.call(*args).tap do |grant|
          allow(grant).to receive(:valid?).and_wrap_original { |validation, *validation_args|
            validation.call(*validation_args)
            true
          }
        end
      end
    end

    it 'fails with the already granted error on the model' do
      expect(organizer).to be_a_failure
      expect(organizer.model.errors.where(:base, :already_granted)).to be_present
      expect(APIAccessGrant.active.count).to eq(1)
    end
  end

  context 'when both actions are granted' do
    before do
      described_class.call(admin:, params: params.merge(action: 'validation'))
      described_class.call(admin:, params:)
    end

    it 'keeps the scopes in a stable order' do
      expect(application.reload.scopes.to_s).to eq('public read_authorizations submit_authorizations validate_authorizations')
    end
  end

  context 'when the scope sync fails' do
    before { application.update_column(:name, '') }

    it 'rolls the grant back' do
      expect { organizer }.to raise_error(ActiveRecord::RecordInvalid)
      expect(APIAccessGrant.count).to eq(0)
    end
  end
end
