RSpec.describe ValidateAPIDataObject do
  describe '#call' do
    subject(:result) { described_class.call(authorization_request_params: params) }

    context 'with an object' do
      let(:params) { ActionController::Parameters.new('intitule' => 'Mon projet') }

      it { is_expected.to be_a_success }
    end

    context 'with an empty object' do
      let(:params) { ActionController::Parameters.new }

      it { is_expected.to be_a_success }
    end

    [nil, 'JVBERi0xLjQK', ['JVBERi0xLjQK'], 42, true].each do |not_an_object|
      context "with #{not_an_object.inspect}" do
        let(:params) { not_an_object }

        it { is_expected.to be_a_failure }

        it 'fails with invalid_data' do
          expect(result.error[:key]).to eq(:invalid_data)
        end
      end
    end
  end
end
