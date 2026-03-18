RSpec.describe Admin::CheckHabilitationTypeDeletable do
  subject(:interactor) { described_class.call(habilitation_type:) }

  let(:habilitation_type) { create(:habilitation_type) }

  context 'when no AuthorizationRequest exists for this type' do
    it { is_expected.to be_success }
  end

  context 'when AuthorizationRequests exist for this type' do
    before do
      allow(habilitation_type).to receive(:authorization_requests_count).and_return(1)
    end

    it { is_expected.to be_failure }

    it 'adds an error on base' do
      expect(interactor.habilitation_type.errors[:base]).not_to be_empty
    end
  end
end
