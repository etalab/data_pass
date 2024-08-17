RSpec.describe AuthorizationRequestChangelogPresenter do
  let(:instance) { described_class.new(changelog) }
  let(:changelog) { AuthorizationRequestChangelog.create!(diff:, authorization_request:) }
  let(:authorization_request) { create(:authorization_request) }

  let(:initial_no_prefilled_data_diff) do
    {
      'attr1' => [nil, 'value1'],
      'attr2' => [nil, 'value2'],
    }
  end

  let(:initial_prefilled_data_unchanged_diff) do
    {
      'attr1' => %w[prefilled_value1 prefilled_value1],
      'attr2' => %w[prefilled_value2 prefilled_value2],
      'attr3' => [nil, 'value3'],
    }
  end

  let(:initial_prefilled_data_changed_diff) do
    {
      'attr1' => %w[prefilled_value1 prefilled_value1],
      'attr2' => %w[prefilled_value2 changed_value2],
      'attr3' => [nil, 'value3'],
    }
  end

  describe '#event_name' do
    subject { instance.event_name }

    context 'when changelog is legacy' do
      before do
        changelog.update!(legacy: true)
      end

      let(:diff) { { what: 'ever' } }

      it { is_expected.to eq('legacy_submit') }
    end

    context 'when it is the first changelog' do
      context 'when all first values are nil (no prefilled data)' do
        let(:diff) { initial_no_prefilled_data_diff }

        it { is_expected.to eq('initial_submit_without_prefilled_data') }
      end

      context 'when not all first values are nil (prefilled data)' do
        context 'when first and second value are same (no changed in prefilled data)' do
          let(:diff) { initial_prefilled_data_unchanged_diff }

          it { is_expected.to eq('initial_submit_without_changes_on_prefilled_data') }
        end

        context 'when first and second value are different (changed in prefilled data)' do
          let(:diff) { initial_prefilled_data_changed_diff }

          it { is_expected.to eq('initial_submit_with_changes_on_prefilled_data') }
        end
      end
    end

    context 'when it is not the first changelog' do
      before do
        create(:authorization_request_event, :submit, authorization_request: changelog.authorization_request)
      end

      context 'when there is no diff' do
        let(:diff) { {} }

        it { is_expected.to eq('submit_without_changes') }
      end

      context 'when there is diff' do
        let(:diff) do
          {
            'attr1' => %w[value1 value2],
          }
        end

        it { is_expected.to eq('submit_with_changes') }
      end
    end
  end

  describe '#consolidated_changelog_entries' do
    subject(:changelog_entries) { instance.consolidated_changelog_entries }

    context 'when it is the first changelog' do
      context 'when all first values are nil (no prefilled data)' do
        let(:diff) { initial_no_prefilled_data_diff }

        it { is_expected.to be_empty }
      end

      context 'when not all first values are nil (prefilled data)' do
        context 'when first and second value are same (no changed in prefilled data)' do
          let(:diff) { initial_prefilled_data_unchanged_diff }

          it { is_expected.to be_empty }
        end

        context 'when first and second value are different (changed in prefilled data)' do
          let(:diff) { initial_prefilled_data_changed_diff }

          it 'renders only the changed prefilled data' do
            expect(changelog_entries.count).to eq(1)
            expect(changelog_entries.first).to match(/Attr2.*a changé.*prefilled_value2.*changed_value2/)
          end
        end
      end
    end

    context 'when it is not the first changelog' do
      before do
        create(:authorization_request_event, :submit, authorization_request: changelog.authorization_request)
      end

      let(:diff) do
        {
          'attr1' => %w[old_value1 new_value1],
          'attr2' => %w[value2 value2],
          'attr3' => [nil, 'value3'],
        }
      end

      it 'displays only keys with changed data' do
        expect(changelog_entries.count).to eq(2)
        expect(changelog_entries[0]).to match(/Attr1.*a changé.*old_value1.*new_value1/)
        expect(changelog_entries[1]).to match(/Attr3.*initialisé.*value3/)
      end
    end
  end
end
