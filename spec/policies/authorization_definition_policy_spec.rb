RSpec.describe AuthorizationDefinitionPolicy do
  let(:instance) { described_class.new(UserContext.new(user), AuthorizationDefinition.find('api_r2p')) }
  let(:user) { create(:user) }

  describe '#new?' do
    subject { instance.new? }

    it { is_expected.to be_truthy }

    context 'when the user is banned' do
      let(:user) { create(:user, banned_at: Time.zone.now, ban_reason: 'Abus') }

      it { is_expected.to be_falsey }
    end
  end
end
