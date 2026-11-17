RSpec.describe 'Wallet registry, step « Le service »' do
  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:user) { create(:user).tap { |applicant| applicant.add_to_organization(organization, current: true) } }
  let(:authorization_request) { create(:authorization_request, :registre_wallet, applicant: user, organization:, **organization_step) }
  let(:organization_step) do
    {
      wallet_privacy_policy_url: 'https://www.clamart.fr/confidentialite',
      wallet_support_email: 'contact@clamart.fr',
      wallet_not_registered_elsewhere: true,
    }
  end
  let(:step_path) { authorization_request_form_build_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id, id: 'service') }
  let(:param_key) { authorization_request.model_name.param_key }
  let(:service) do
    {
      wallet_service_name: 'Vélocité Libre-service',
      wallet_service_identifier: 'libre-service',
      wallet_service_description: 'Location de vélos en libre-service dans la métropole de Lyon.',
    }
  end

  before { sign_in(user) }

  def click_next(fields)
    patch step_path, params: { next: '', param_key => fields }
  end

  describe 'GET the step' do
    before { get step_path }

    it 'shows the three fields, the counter and the read-only entitlement' do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Étape 2/2', 'Quel service demandera des données au wallet ?', '0/50 caractères')
      expect(response.body).to include("#{param_key}_wallet_service_name", "#{param_key}_wallet_service_identifier", "#{param_key}_wallet_service_description")
      expect(response.body).to include('Habilitation du service', 'Fournisseur de services (Service_Provider)', 'aria-labelledby="wallet-service-card-title"')
    end

    it 'hides the wallet preview from screen readers, since it repeats the name' do
      expect(response.body).to include('<div class="wx-wallet" aria-hidden="true">')
    end

    it 'shows « ? » in the preview avatar while the service has no name' do
      expect(response.body).to include('<span class="wx-avatar" data-wallet-service-target="previewInitial">?</span>')
    end

    it 'offers no field for the entitlement' do
      expect(response.body).not_to include('wallet_entitlement')
    end
  end

  describe 'clicking « Suivant » on an empty step' do
    before { click_next(wallet_service_name: '') }

    it 'stays on the step with the three points to fix' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('3 points à corriger avant de continuer', "href=\"##{param_key}_wallet_service_name\"")
    end
  end

  describe 'clicking « Suivant » with a name of 51 characters (CA2)' do
    before { click_next(service.merge(wallet_service_name: 'V' * 51)) }

    it 'stays on the step, the counter is in error and a message asks to shorten it' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('51/50 caractères', 'wx-count is-over', 'Le nom du service compte 51 caractères. Raccourcissez-le à 50 caractères au plus')
    end
  end

  describe 'clicking « Suivant » with a badly formatted identifier' do
    before { click_next(service.merge(wallet_service_identifier: 'Libre_Service')) }

    it 'names the field in the error summary' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Identifiant du service : format non valide.')
    end
  end

  describe 'clicking « Suivant » with the description « test » (CA4)' do
    before { click_next(service.merge(wallet_service_description: 'test')) }

    it 'stays on the step with a message linked to the field' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Description du service : trop courte.', "href=\"##{param_key}_wallet_service_description\"")
    end
  end

  describe 'identifier already used by another service of the organization' do
    let(:other_applicant) { create(:user).tap { |applicant| applicant.add_to_organization(organization, current: true) } }

    before do
      create(:authorization_request, :registre_wallet, state_trait, organization:, applicant: other_applicant, wallet_service_identifier: 'libre-service')
      click_next(service)
    end

    context 'when that request is being verified (CA3)' do
      let(:state_trait) { :submitted }

      it 'stays on the step with a message linked to the field' do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Un autre service de votre organisation utilise déjà cet identifiant. Choisissez-en un autre.', "href=\"##{param_key}_wallet_service_identifier\"")
      end
    end

    context 'when that request is a draft of another person (CA9)' do
      let(:state_trait) { :draft }

      it 'goes on to the summary' do
        expect(response).to have_http_status(:redirect)
        expect(authorization_request.reload.wallet_service_identifier).to eq('libre-service')
      end
    end
  end

  describe 'clicking « Suivant » with the three fields filled (CA1)' do
    before { click_next(service) }

    it 'saves the service in the draft' do
      expect(response).to have_http_status(:redirect)
      expect(authorization_request.reload.data.slice('wallet_service_name', 'wallet_service_identifier', 'wallet_service_description').values).to eq(service.values)
    end
  end
end
