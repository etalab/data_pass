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
end
