RSpec.describe WalletRegistryHelper do
  describe '#wallet_registry_commitment_label' do
    subject(:label) { helper.wallet_registry_commitment_label(authorization_request) }

    let(:organization) { create(:organization, siret: '21920023500022') }
    let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:) }

    context 'when the legal name is known' do
      it { is_expected.to eq('Je déclare que COMMUNE DE CLAMART n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union.') }
    end

    context 'when the legal name is typed by the applicant' do
      let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:, identity_source: 'sirene_unavailable', identity_legal_name: nil, wallet_legal_name: 'MAIRIE DE CLAMART') }

      it { is_expected.to include('Je déclare que MAIRIE DE CLAMART n’est') }
    end

    context 'when the legal name is not known yet' do
      let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:, identity_source: 'sirene_pending', identity_legal_name: nil) }

      it 'speaks of « votre organisation », without the SIRET' do
        expect(label).to eq('Je déclare que votre organisation n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union.')
      end
    end
  end

  describe '#wallet_registry_phone' do
    {
      '0146629000' => '01 46 62 90 00',
      '01.46.62.90.00' => '01 46 62 90 00',
      '+33 1 46 62 90 02' => '01 46 62 90 02',
      '+33 (0)4 72 00 00 01' => '+33 (0)4 72 00 00 01',
      '+590 690 12 34 56' => '+590 6 90 12 34 56',
      '+687 12 34 56' => '+687 12 34 56',
      '12 ab' => '12 ab',
    }.each do |entered, displayed|
      it "shows « #{entered} » as « #{displayed} »" do
        expect(helper.wallet_registry_phone(entered)).to eq(displayed)
      end
    end
  end
end
