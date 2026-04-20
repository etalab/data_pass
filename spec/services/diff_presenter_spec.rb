RSpec.describe DiffPresenter do
  subject(:entries) { described_class.new(diff, authorization_request).entries }

  let(:authorization_request) { create(:authorization_request) }

  describe '#entries' do
    context 'with simple attribute changes' do
      let(:diff) do
        {
          'attr1' => %w[old_value1 new_value1],
          'attr3' => [nil, 'value3'],
        }
      end

      it 'displays changed attributes' do
        expect(entries.count).to eq(2)
        expect(entries[0]).to match(/Attr1.*a changé.*old_value1.*new_value1/)
        expect(entries[1]).to match(/Attr3.*initialisé.*value3/)
      end
    end

    context 'with unchanged values' do
      let(:diff) do
        {
          'attr1' => %w[old_value1 new_value1],
          'attr2' => %w[same_value same_value],
        }
      end

      it 'filters out unchanged entries' do
        expect(entries.count).to eq(1)
        expect(entries[0]).to match(/Attr1/)
      end
    end

    context 'with an empty diff' do
      let(:diff) { {} }

      it { is_expected.to be_empty }
    end

    context 'with an integer as a value' do
      let(:diff) do
        {
          'attr1' => [1, 2],
        }
      end

      it 'displays the integer' do
        expect(entries.count).to eq(1)
        expect(entries[0]).to match(/Attr1.*a changé.*1.*2/)
      end
    end

    context 'with scopes key within diff' do
      let(:diff) do
        {
          'scopes' => [%w[scope1 scope2], %w[scope2 scope3]],
        }
      end

      it 'displays adds and removes' do
        expect(entries.count).to eq(2)
        expect(entries[0]).to match(/Le périmètre de données.*scope3.*ajouté/)
        expect(entries[1]).to match(/Le périmètre de données.*scope1.*retiré/)
      end
    end

    context 'with scopes key within diff and first entry nil' do
      let(:diff) do
        {
          'scopes' => [nil, %w[scope2 scope3]],
        }
      end

      it 'displays adds' do
        expect(entries.count).to eq(2)
        expect(entries[0]).to match(/Le périmètre de données.*scope2.*ajouté/)
        expect(entries[1]).to match(/Le périmètre de données.*scope3.*ajouté/)
      end
    end

    context 'with modalities key within diff' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }
      let(:diff) do
        {
          'modalities' => [%w[params], %w[formulaire_qf]],
        }
      end

      it 'displays adds and removes' do
        expect(entries.count).to eq(2)
        expect(entries[0]).to match(/La modalité.*Formulaire QF.*ajouté/)
        expect(entries[1]).to match(/La modalité.*Jeton.*retiré/)
      end
    end
  end
end
