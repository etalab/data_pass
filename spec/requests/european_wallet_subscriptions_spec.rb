RSpec.describe 'POST /portefeuille-europeen/inscription' do
  def subscribe(email: 'jean.dupont@example.com')
    post european_wallet_subscriptions_path, params: { european_wallet_subscriber: { email:, profile: 'intermediary' } }
  end

  context 'when the subscription parameter is not a form' do
    it 'answers with the profile and address errors' do
      post european_wallet_subscriptions_path, params: { european_wallet_subscriber: 'texte' }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Choisissez ce qui vous décrit.')
    end
  end

  context 'when the subscription cannot be saved' do
    before do
      allow(EuropeanWalletSubscriber).to receive(:find_or_initialize_by).and_raise(ActiveRecord::ConnectionNotEstablished)
      allow(Sentry).to receive(:capture_exception)
    end

    it 'tells the visitor the subscription did not go through, without confirming it' do
      subscribe

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Votre inscription n’a pas abouti')
      expect(response.body).not_to include('Votre inscription est enregistrée')
    end

    it 'keeps the address typed by the visitor' do
      subscribe

      expect(response.body).to include('value="jean.dupont@example.com"')
    end
  end

  context 'when more than 10 subscriptions come from the same IP within a minute' do
    before { 10.times { |index| subscribe(email: "inscrit#{index}@example.com") } }

    it 'refuses the next one' do
      expect { subscribe }.not_to change(EuropeanWalletSubscriber, :count)

      expect(response).to have_http_status(:too_many_requests)
      expect(response.body).to include('Nous avons reçu trop d’inscriptions depuis votre connexion')
    end
  end
end
