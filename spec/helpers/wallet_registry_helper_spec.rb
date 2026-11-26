RSpec.describe WalletRegistryHelper do
  describe '#wallet_registry_commitment_label' do
    subject(:label) { helper.wallet_registry_commitment_label(authorization_request) }

    let(:organization) { create(:organization, siret: '21920023500022') }
    let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:) }

    context 'when the legal name is known' do
      it { is_expected.to eq('Je déclare que COMMUNE DE CLAMART n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union.') }
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

  describe '#wallet_registry_organization_name' do
    let(:organization) { instance_double(Organization, denomination: nil) }
    let(:authorization_request) { instance_double(AuthorizationRequest::RegistreWallet, identity_legal_name: nil, organization:) }

    it 'says « votre organisation » rather than a SIRET when no name is known yet' do
      expect(helper.wallet_registry_organization_name(authorization_request)).to eq('votre organisation')
    end

    it 'prefers the name read in Sirene' do
      allow(authorization_request).to receive(:identity_legal_name).and_return('COMMUNE DE CLAMART')

      expect(helper.wallet_registry_organization_name(authorization_request)).to eq('COMMUNE DE CLAMART')
    end
  end

  describe '#wallet_registry_applicant_link' do
    def link_for(public_sector)
      helper.wallet_registry_applicant_link(instance_double(AuthorizationRequest::RegistreWallet, identity_public_sector: public_sector, identity_legal_category_code: '7210'))
    end

    it 'names a public agent of the commune' do
      expect(link_for('true')).to eq('Agent de la commune, connecté par ProConnect avec le compte de son administration')
    end

    it 'names a certified executive of a private organization' do
      expect(link_for('false')).to start_with('Dirigeant de la commune')
    end

    it 'claims nothing while the public sector of the organization is unknown' do
      expect(link_for(nil)).to eq('À confirmer, une fois les informations de la commune récupérées')
    end
  end

  describe '#wallet_registry_person_name' do
    it 'writes the given name first, in normal case, accents kept' do
      user = build(:user, given_name: 'YASMINE marie-ÉLODIE', family_name: 'DEMANDEUSE COMMUNE')

      expect(helper.wallet_registry_person_name(user)).to eq('Yasmine Marie-Élodie Demandeuse Commune')
    end
  end
end
