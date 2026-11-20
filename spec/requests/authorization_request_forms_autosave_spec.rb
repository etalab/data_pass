RSpec.describe 'Autosave of an authorization request draft' do
  subject(:autosave) do
    patch authorization_request_form_autosave_path(form_uid: authorization_request.form_uid, authorization_request_id: authorization_request.id),
      params: { param_key => attributes },
      headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

    response
  end

  let(:user) { create(:user) }
  let(:authorization_request) { create(:authorization_request, :registre_wallet, applicant: user) }
  let(:param_key) { authorization_request.model_name.param_key }
  let(:attributes) { { wallet_website_url: 'https://www.clamart.fr' } }

  let(:signed_in) { true }

  before { sign_in(user) if signed_in }

  context 'with the wallet registry, which enables autosave' do
    it 'saves the incomplete draft and refreshes the last save time' do
      expect(autosave).to have_http_status(:ok)
      expect(response.body).to include('wallet-saved-at', 'Brouillon enregistré à')
      expect(authorization_request.reload.wallet_website_url).to eq('https://www.clamart.fr')
    end

    context 'with a badly formatted value' do
      let(:attributes) { { wallet_website_url: 'http://www.clamart.fr', wallet_support_email: 'contact@clamart.fr' } }

      it 'saves the other values, sets the badly formatted one aside and says so' do
        expect(autosave).to have_http_status(:ok)
        expect(response.body).to include('une valeur non enregistrée, au format invalide')
        expect([authorization_request.reload.wallet_support_email, authorization_request.wallet_website_url]).to eq(['contact@clamart.fr', nil])
      end
    end

    it 'creates no event' do
      expect { autosave }.not_to change(AuthorizationRequestEvent, :count)
    end

    it 'sends no email' do
      expect { autosave }.not_to have_enqueued_mail
    end

    it 'sends no webhook' do
      expect { autosave }.not_to have_enqueued_job(DeliverAuthorizationRequestWebhookJob)
    end
  end

  context 'with a definition without autosave' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }
    let(:attributes) { { intitule: 'Nouveau titre' } }

    it 'refuses without a flash message' do
      expect(autosave).to have_http_status(:forbidden)
      expect(flash[:error]).to be_nil
      expect(authorization_request.reload.intitule).not_to eq('Nouveau titre')
    end
  end

  context 'with an archived draft' do
    before { authorization_request.update!(state: 'archived') }

    it { expect(autosave).to have_http_status(:forbidden) }
  end

  context 'with a draft of another user' do
    let(:authorization_request) { create(:authorization_request, :registre_wallet) }

    it { expect(autosave).to have_http_status(:forbidden) }
  end

  context 'when the session has ended' do
    let(:signed_in) { false }

    it 'answers unauthorized instead of the sign in page' do
      expect(autosave).to have_http_status(:unauthorized)
    end

    it 'does not come back to the autosave address after sign in' do
      autosave

      expect(session[:return_to_after_sign_in]).to be_nil
    end
  end
end
