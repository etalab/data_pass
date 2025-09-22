RSpec.describe OrganizationDecorator, type: :decorator do
  describe '#adresse' do
    subject { organization.decorate.address }

    context 'with organization is from INSEE Sirene registry' do
      let(:organization) { create(:organization, siret: '13002526500013') }

      it do
        expect(subject).to eq('20 AV DE SEGUR<br />75007 PARIS 7')
      end
    end

    context 'when organization is from foreign registry but with address within extra_legal_entity_infos' do
      let(:organization) { create(:organization, :foreign, extra_legal_entity_infos: { 'address' => 'Foreign address' }) }

      it { is_expected.to eq('Foreign address') }
    end
  end

  describe '#code_naf_with_libelle' do
    subject { organization.decorate.code_naf_with_libelle }

    let(:organization) do
      create(:organization,
        legal_entity_registry: 'insee_sirene',
        insee_payload: {
          'etablissement' => {
            'uniteLegale' => {
              'activitePrincipaleUniteLegale' => code_naf
            }
          }
        })
    end

    context 'when code_naf is nil' do
      let(:code_naf) { nil }

      it { is_expected.to be_nil }
    end

    context 'when code_naf is blank' do
      let(:code_naf) { '' }

      it { is_expected.to be_nil }
    end

    context 'when code_naf is 0000Z' do
      let(:code_naf) { '0000Z' }

      it { is_expected.to eq('0000Z - Activité inconnue') }
    end

    context 'when code_naf is valid' do
      let(:code_naf) { '0112Z' }

      it { is_expected.to eq('0112Z - Culture du riz') }
    end

    context 'when code_naf is invalid (not 0000Z)' do
      let(:code_naf) { '9999X' }

      it { is_expected.to eq('9999X - Activité inconnue') }
    end
  end
end
