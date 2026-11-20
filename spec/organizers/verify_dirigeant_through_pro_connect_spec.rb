RSpec.describe VerifyDirigeantThroughProConnect do
  subject(:verify) { described_class.call(user:, organization:, pro_connect_omniauth_payload: payload) }

  let(:user) { create(:user) }
  let(:organization) { user.current_organization }
  let(:siren) { organization.siret.first(9) }
  let(:acr) { OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE }
  let(:returned_siret) { "#{siren}00099" }
  let(:sub) { user.external_id }
  let(:payload) do
    {
      'uid' => sub,
      'info' => { 'email' => user.email },
      'extra' => { 'acr' => acr, 'amr' => %w[pwd mfa], 'raw_info' => { 'sub' => sub, 'siret' => returned_siret } }
    }
  end

  context 'when ProConnect certified the user as dirigeant of an establishment of the organization' do
    it { is_expected.to be_success }

    it 'describes the verification' do
      expect(verify.verification).to include(
        siren:,
        siret: returned_siret,
        sub:,
        acr:,
        amr: %w[pwd mfa]
      )
    end

    it 'persists nothing' do
      expect { verify }.not_to(change { [user.reload.updated_at, organization.reload.updated_at] })
    end
  end

  context 'when the acr is not the dirigeant certification' do
    let(:acr) { 'eidas1-mfa' }

    it { is_expected.to be_failure }

    it 'gives the reason' do
      expect(verify.error).to eq(:acr_not_dirigeant)
      expect(verify.verification).to be_nil
    end
  end

  context 'when the ProConnect account is not the signed in one' do
    let(:sub) { 'another-sub' }

    it 'fails with identity_mismatch' do
      expect(verify.error).to eq(:identity_mismatch)
    end
  end

  context 'when the returned SIRET belongs to another SIREN' do
    let(:returned_siret) { '13002526500013' }

    it 'fails with siret_outside_siren' do
      expect(verify.error).to eq(:siret_outside_siren)
    end
  end

  context 'when no SIRET is returned' do
    let(:returned_siret) { nil }

    it 'fails with siret_outside_siren' do
      expect(verify.error).to eq(:siret_outside_siren)
    end
  end

  context 'when the organization has no SIRET' do
    let(:organization) { create(:organization, :foreign) }
    let(:returned_siret) { '13002526500013' }

    it 'fails with organization_without_siren' do
      expect(verify.error).to eq(:organization_without_siren)
    end
  end
end
