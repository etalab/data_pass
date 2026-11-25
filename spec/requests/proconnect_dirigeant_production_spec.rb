RSpec.describe 'ProConnect dirigeant journey in production' do
  let(:user) { create(:user) }

  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    sign_in(user)
  end

  context 'when its setting is not set' do
    it 'does not serve the dirigeant verification page' do
      get dirigeant_verification_path

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when its setting opens the journey' do
    before { Setting.set(:proconnect_dirigeant_open, 'true') }

    it 'serves the dirigeant verification page' do
      get dirigeant_verification_path

      expect(response).to have_http_status(:ok)
    end
  end
end
