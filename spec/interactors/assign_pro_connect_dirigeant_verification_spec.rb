RSpec.describe AssignProConnectDirigeantVerification do
  subject(:assign) { described_class.call(organization:, pro_connect_omniauth_payload: payload) }

  let(:user) { create(:user) }
  let(:organization) { user.current_organization }
  let(:siren) { organization.siret.first(9) }
  let(:acr) { OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE }
  let(:payload) do
    {
      'uid' => user.external_id,
      'extra' => { 'acr' => acr, 'amr' => %w[pwd mfa], 'raw_info' => { 'siret' => "#{siren}00099" } }
    }
  end

  it 'describes the verification' do
    freeze_time do
      expect(assign.verification).to eq(
        siren:,
        siret: "#{siren}00099",
        sub: user.external_id,
        acr:,
        amr: %w[pwd mfa],
        verified_at: Time.zone.now
      )
    end
  end

  it 'persists nothing' do
    expect { assign }.not_to(change { [user.reload.updated_at, organization.reload.updated_at] })
  end
end
