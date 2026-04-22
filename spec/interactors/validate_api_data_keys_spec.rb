RSpec.describe ValidateAPIDataKeys do
  describe '#call' do
    subject(:result) do
      described_class.call(
        authorization_request_params: ActionController::Parameters.new(params),
        authorization_request_form: authorization_request_form
      )
    end

    let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise') }

    context 'with valid keys' do
      let(:params) { { 'intitule' => 'Mon projet' } }

      it { is_expected.to be_a_success }
    end

    context 'with invalid keys' do
      let(:params) { { 'nonexistent_field' => 'value' } }

      it { is_expected.to be_a_failure }

      it 'fails with invalid_data_keys and exposes the keys' do
        expect(result.error[:key]).to eq(:invalid_data_keys)
        expect(result.error[:errors]).to eq(['nonexistent_field'])
      end
    end

    context 'with a mix of valid and invalid keys' do
      let(:params) { { 'intitule' => 'Mon projet', 'unknown_key' => 'value' } }

      it { is_expected.to be_a_failure }

      it 'fails with only the invalid keys' do
        expect(result.error[:key]).to eq(:invalid_data_keys)
        expect(result.error[:errors]).to eq(['unknown_key'])
      end
    end

    context 'with checkbox keys' do
      let(:params) { { 'terms_of_service_accepted' => '1' } }

      it { is_expected.to be_a_failure }
    end
  end
end
