RSpec.describe DGFIP::ExportController do
  describe '#show' do
    subject(:get_spreadsheet) { get :show }

    let!(:dgfip_provider) { create(:data_provider, :dgfip) }

    before do
      sign_in(user)
    end

    describe 'access' do
      context 'when admin' do
        let(:user) { create(:user, :admin) }

        it { is_expected.to have_http_status(:ok) }
      end

      context 'when dgfip reporter' do
        let(:user) { create(:user, :reporter, authorization_request_types: %w[api_impot_particulier]) }

        it { is_expected.to have_http_status(:ok) }
      end

      context 'when another reporter' do
        let(:user) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    describe 'response body' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[api_impot_particulier]) }

      it 'is expected to be a spreadsheet' do
        get_spreadsheet

        expect(Marcel::MimeType.for(response.body)).to include('spreadsheet')
      end
    end
  end
end
