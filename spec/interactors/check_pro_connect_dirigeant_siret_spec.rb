RSpec.describe CheckProConnectDirigeantSiret do
  subject(:check) do
    described_class.call(organization:, pro_connect_omniauth_payload: { 'extra' => { 'raw_info' => { 'siret' => returned_siret } } })
  end

  let(:organization) { create(:organization) }
  let(:returned_siret) { "#{organization.siret.first(9)}00099" }

  context 'when the returned SIRET is an establishment of the organization' do
    it { is_expected.to be_success }
  end

  context 'when the returned SIRET belongs to another SIREN' do
    let(:returned_siret) { '13002526500013' }

    it 'fails with siret_outside_siren' do
      expect(check).to be_failure
      expect(check.error).to eq(:siret_outside_siren)
    end
  end

  context 'when no SIRET is returned' do
    let(:returned_siret) { nil }

    it 'fails with siret_outside_siren' do
      expect(check.error).to eq(:siret_outside_siren)
    end
  end

  context 'when the organization has no SIRET' do
    let(:organization) { create(:organization, :foreign) }
    let(:returned_siret) { '13002526500013' }

    it 'fails with organization_without_siren' do
      expect(check.error).to eq(:organization_without_siren)
    end
  end
end
