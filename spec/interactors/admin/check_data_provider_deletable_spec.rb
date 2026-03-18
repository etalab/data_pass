RSpec.describe Admin::CheckDataProviderDeletable do
  subject(:interactor) { described_class.call(data_provider:) }

  let(:data_provider) { create(:data_provider) }

  context 'when no HabilitationType nor static AuthorizationDefinition is linked' do
    it { is_expected.to be_success }
  end

  context 'when a HabilitationType is linked' do
    before { create(:habilitation_type, data_provider:) }

    it { is_expected.to be_failure }

    it 'adds an error on base' do
      expect(interactor.data_provider.errors[:base]).not_to be_empty
    end
  end

  context 'when a static AuthorizationDefinition references the slug' do
    before do
      allow(data_provider).to receive(:authorization_definitions).and_return([double])
    end

    it { is_expected.to be_failure }
  end
end
