RSpec.describe EnsureAuthorizationRequestIsUpdatable do
  subject(:result) { described_class.call(authorization_request:) }

  %i[draft changes_requested].each do |state|
    context "when the request is #{state}" do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, state) }

      it { is_expected.to be_a_success }
    end
  end

  %i[submitted validated refused].each do |state|
    context "when the request is #{state}" do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, state) }

      it 'fails with dead_end_state' do
        expect(result).to be_a_failure
        expect(result.error[:key]).to eq(:dead_end_state)
      end
    end
  end
end
