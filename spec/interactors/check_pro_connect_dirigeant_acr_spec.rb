RSpec.describe CheckProConnectDirigeantACR do
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

  context 'when the user was certified as dirigeant of the organization' do
    subject(:check) { described_class.call(user:, organization:, pro_connect_omniauth_payload: { 'extra' => { 'acr' => acr } }) }

    let(:user) { create(:user) }
    let(:organization) { user.current_organization }
    let(:organization_link) { user.organizations_users.find_by(organization:) }
    let(:certified_at) { 1.day.ago.change(usec: 0) }

    before { organization_link.update!(dirigeant_verified_at: certified_at) }

    it 'keeps the certification when ProConnect certifies again' do
      expect { check }.not_to(change { organization_link.reload.dirigeant_verified_at })
    end

    context 'when ProConnect no longer certifies the dirigeant status' do
      let(:acr) { 'eidas1-mfa' }

      it 'revokes the certification' do
        expect { check }.to change { organization_link.reload.dirigeant_verified_at }.from(certified_at).to(nil)
      end
    end
  end
end
