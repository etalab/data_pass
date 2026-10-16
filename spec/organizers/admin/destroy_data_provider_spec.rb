RSpec.describe Admin::DestroyDataProvider do
  subject(:organizer) { described_class.call(admin: create(:user, :admin), data_provider:) }

  let!(:data_provider) { create(:data_provider) }

  context 'when data provider has no linked types' do
    it { is_expected.to be_success }

    it 'destroys the data provider' do
      expect { organizer }.to change(DataProvider, :count).by(-1)
    end

    it 'tracks the event' do
      expect { organizer }.to change(AdminEvent, :count).by(1)
    end
  end

  context 'when a HabilitationType is linked' do
    before { create(:habilitation_type, data_provider:) }

    it { is_expected.to be_failure }

    it 'does not destroy the data provider' do
      expect { organizer }.not_to change(DataProvider, :count)
    end
  end

  context 'when a static AuthorizationDefinition references the slug' do
    before { allow(data_provider).to receive(:authorization_definitions).and_return([double]) }

    it { is_expected.to be_failure }

    it 'does not destroy the data provider' do
      expect { organizer }.not_to change(DataProvider, :count)
    end
  end

  context 'when API access grants exist' do
    let(:data_provider) { DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum') }
    let(:other_provider) { DataProvider.find_by(slug: 'dgfip') || create(:data_provider, slug: 'dgfip') }
    let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise api_impot_particulier]) }
    let(:application) do
      create(:oauth_application, owner:, scopes: 'public submit_authorizations validate_authorizations')
    end

    before do
      create(:api_access_grant, data_provider:, oauth_application: application)
      create(:api_access_grant, :revoked, :validation, data_provider:, oauth_application: application)
      create(:api_access_grant, :validation, data_provider: other_provider, oauth_application: application)
      allow(data_provider).to receive(:authorization_definitions).and_return([])
    end

    it { is_expected.to be_success }

    it 'removes active and revoked grants of the data provider only' do
      expect { organizer }.to change { APIAccessGrant.where(data_provider_id: data_provider.id).count }.from(2).to(0)
      expect(APIAccessGrant.where(data_provider_id: other_provider.id).count).to eq(1)
    end

    it 'removes the unjustified scope and keeps the one justified by another grant' do
      organizer

      expect(application.reload.scopes.to_a).to match_array(%w[public validate_authorizations])
    end
  end
end
