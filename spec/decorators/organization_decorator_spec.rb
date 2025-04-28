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
end
