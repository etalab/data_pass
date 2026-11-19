RSpec.describe CheckProConnectDirigeantAcr do
  subject(:check) { described_class.call(pro_connect_omniauth_payload: { 'extra' => { 'acr' => acr } }) }

  let(:acr) { OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE }

  it { is_expected.to be_success }

  context 'when the acr is not the dirigeant certification' do
    let(:acr) { 'eidas1-mfa' }

    it 'fails with acr_not_dirigeant' do
      expect(check).to be_failure
      expect(check.error).to eq(:acr_not_dirigeant)
    end
  end

  context 'when no acr is returned' do
    let(:acr) { nil }

    it 'fails with acr_not_dirigeant' do
      expect(check.error).to eq(:acr_not_dirigeant)
    end
  end
end
