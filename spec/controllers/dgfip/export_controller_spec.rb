RSpec.describe DGFIP::ExportController, type: :controller do
  describe '#show' do
    subject(:get_spreadsheet) { get :show }

    before do
      sign_in(user)
    end

    describe 'access' do
      context 'when admin' do
        let(:user) { create(:user, roles: %w[admin]) }

        it { is_expected.to have_http_status(200) }
      end

      context 'when dgfip reporter' do
        let(:user) { create(:user, roles: %w[api_impot_particulier:reporter]) }

        it { is_expected.to have_http_status(200) }
      end

      context 'when another reporter' do
        let(:user) { create(:user, roles: %w[api_whatever:reporter]) }

        it { is_expected.to have_http_status(403) }
      end
    end

    describe 'response body' do
      let(:user) { create(:user, roles: %w[api_impot_particulier:reporter]) }

      it 'is expected to be a spreadsheet' do
        get_spreadsheet

        expect(Marcel::MimeType.for(response.body)).to include('spreadsheet')
      end
    end
  end
end
