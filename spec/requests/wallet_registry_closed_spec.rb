RSpec.describe 'Wallet registry closed by its feature flag' do
  before do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with('registre_wallet').and_return(false)
  end

  shared_examples 'a registry that does not exist' do
    it 'treats the form as not found' do
      get '/formulaires/registre-wallet/demande/nouveau'

      expect(response).to redirect_to('/')
      expect(flash[:alert]).to eq(I18n.t('authorization_request_forms.form_not_found'))
    end

    it 'treats the definition as not found' do
      get '/demandes/registre_wallet/nouveau'

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when signed out' do
    it_behaves_like 'a registry that does not exist'
  end

  context 'when signed in' do
    before { sign_in(create(:user)) }

    it_behaves_like 'a registry that does not exist'

    it 'does not start a request' do
      get '/formulaires/registre-wallet/demande/commencer'

      expect(response).to redirect_to('/')
    end
  end
end
