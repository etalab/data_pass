RSpec.describe ValidateAPIMetadata do
  describe '#call' do
    subject(:result) { described_class.call(api_metadata:, api_metadata_provided:) }

    let(:api_metadata_provided) { true }

    context 'when no metadata were sent' do
      let(:api_metadata_provided) { false }
      let(:api_metadata) { nil }

      it { is_expected.to be_a_success }
    end

    context 'with null metadata' do
      let(:api_metadata) { nil }

      it { is_expected.to be_a_success }
    end

    context 'with valid metadata' do
      let(:api_metadata) { { 'campagne' => 'migration-editeur-x' } }

      it { is_expected.to be_a_success }
    end

    context 'with invalid metadata' do
      let(:api_metadata) { { 'campagne' => 'migration-editeur-x', 'source' => { 'canal' => 'api' } } }

      it 'fails with one violation per invalid entry' do
        expect(result.error).to include(key: :invalid_metadata, format: :metadata)
        expect(result.error[:errors].map { |error| error.options[:key] }).to eq(%w[source])
      end
    end

    context 'when metadata are not an object' do
      let(:api_metadata) { 'migration' }

      it { is_expected.to be_a_failure }
    end
  end
end
