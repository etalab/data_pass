RSpec.describe Admin::BuildAdminChangeDiff, type: :interactor do
  describe '.call' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise) }

    context 'with a block that modifies data' do
      let(:block) do
        proc { |ar|
          ar.update!(data: ar.data.merge('intitule' => 'Nouveau titre'))
        }
      end

      it 'computes the diff from data changes' do
        old_intitule = authorization_request.data['intitule']

        result = described_class.call(authorization_request:, block:)

        expect(result.diff).to include('intitule' => [old_intitule, 'Nouveau titre'])
      end
    end

    context 'with a block that does not modify data' do
      let(:block) { proc { |_ar| } }

      it 'returns an empty diff' do
        result = described_class.call(authorization_request:, block:)

        expect(result.diff).to eq({})
      end
    end

    context 'with a block that modifies data without saving' do
      let(:block) do
        proc { |ar|
          ar.data['intitule'] = 'Changement non sauvegardé'
        }
      end

      it 'raises an error' do
        expect {
          described_class.call(authorization_request:, block:)
        }.to raise_error(RuntimeError, I18n.t('admin.build_admin_change_diff.unsaved_changes'))
      end
    end

    context 'without a block' do
      it 'returns an empty diff' do
        result = described_class.call(authorization_request:)

        expect(result.diff).to eq({})
      end
    end
  end
end
