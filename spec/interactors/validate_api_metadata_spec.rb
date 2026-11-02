RSpec.describe ValidateAPIMetadata do
  describe '#call' do
    subject(:result) { described_class.call(api_metadata:) }

    def violations
      result.error[:errors].map { |error| [error.options[:key], error.attribute, error.type] }
    end

    context 'when no metadata were sent' do
      let(:api_metadata) { nil }

      it { is_expected.to be_a_success }
    end

    context 'with an empty object, which erases the metadata' do
      let(:api_metadata) { {} }

      it { is_expected.to be_a_success }
    end

    context 'with scalar values at the limits' do
      let(:api_metadata) do
        (1..15).to_h { |index| ["cle_#{index}", 'valeur'] }
          .merge('a' * 40 => 'valeur', 'longue' => 'v' * 500, 'lot' => 9_007_199_254_740_991, 'prioritaire' => false, 'ratio' => 0.5)
      end

      it { is_expected.to be_a_success }
    end

    context 'when metadata are not an object' do
      let(:api_metadata) { 'migration' }

      it { expect(violations).to eq([[nil, :content, :not_an_object]]) }
    end

    context 'with 21 keys' do
      let(:api_metadata) { (1..21).to_h { |index| ["cle_#{index}", 'valeur'] } }

      it { expect(violations).to eq([[nil, :content, :too_long]]) }
    end

    context 'with invalid entries' do
      let(:api_metadata) do
        {
          'a' * 41 => 'valeur',
          'date de création' => 'valeur',
          'source' => { 'canal' => 'api' },
          'lots' => [1, 2],
          'vide' => nil,
          'infini' => Float::INFINITY,
          'commentaire' => 'v' * 501,
          'nul' => "a\u0000b",
          'enorme' => 9_007_199_254_740_992
        }
      end

      it 'fails with one violation per invalid entry' do
        expect(result.error).to include(key: :invalid_metadata, format: :metadata)
        expect(violations).to eq([
          ['a' * 41, :key, :too_long],
          ['date de création', :key, :invalid],
          ['source', :value, :not_scalar],
          ['lots', :value, :not_scalar],
          ['vide', :value, :not_scalar],
          ['infini', :value, :not_scalar],
          ['commentaire', :value, :too_long],
          ['nul', :value, :invalid],
          ['enorme', :value, :out_of_range]
        ])
      end
    end
  end
end
