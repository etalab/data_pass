RSpec.describe Instruction::AuthorizationRequestPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), authorization_request) }

  let(:user) { create(:user, :instructor, authorization_request_types: %i[api_sfip]) }

  describe '#cancel_next_stage?' do
    subject { policy.cancel_next_stage? }

    context 'when production request comes from a validated sandbox' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_production, :submitted) }

      it { is_expected.to be true }
    end

    context 'when production request was created through an editor form' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_editeur, :submitted) }

      it { is_expected.to be false }
    end

    context 'when user is not an instructor for the request type' do
      let(:user) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }
      let(:authorization_request) { create(:authorization_request, :api_sfip_production, :submitted) }

      it { is_expected.to be false }
    end
  end

  describe '#moderate?' do
    subject { policy.moderate? }

    context 'when editor request is submitted' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_editeur, :submitted) }

      it { is_expected.to be true }
    end

    context 'when editor request is a first draft' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_editeur, :draft) }

      it { is_expected.to be true }
    end
  end
end
