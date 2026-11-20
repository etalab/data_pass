RSpec.describe CheckProConnectDirigeantIdentity do
  subject(:check) { described_class.call(user:, pro_connect_omniauth_payload: { 'uid' => uid }) }

  let(:user) { create(:user) }
  let(:uid) { user.external_id }

  it { is_expected.to be_success }

  context 'with another sub' do
    let(:uid) { 'another-sub' }

    it { is_expected.to be_failure }
  end

  context 'when the user has no external_id' do
    let(:user) { create(:user, external_id: nil) }
    let(:uid) { nil }

    it { is_expected.to be_failure }
  end
end
