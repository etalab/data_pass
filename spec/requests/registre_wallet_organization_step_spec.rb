RSpec.describe 'Wallet registry, step « L’organisation »' do
  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:user) { create(:user).tap { |applicant| applicant.add_to_organization(organization, current: true) } }
  let(:authorization_request) { create(:authorization_request, :registre_wallet, applicant: user, organization:) }
  let(:step_path) { authorization_request_form_build_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id, id: 'organisation') }
  let(:param_key) { authorization_request.model_name.param_key }

  before { sign_in(user) }

  describe 'GET the step' do
    before { get step_path }

    it 'shows the identity read from the INSEE data and the published fields' do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('COMMUNE DE CLAMART', 'Agent connecté par ProConnect', 'Brouillon enregistré à', 'Étape 1/3')
      expect(response.body).to include("#{param_key}_wallet_privacy_policy_url", 'type="tel"', 'novalidate')
    end

    it 'gives the published fields their autocomplete purpose (RGAA 11.13)' do
      expect(response.body).to include('autocomplete="url"', 'autocomplete="email"', 'autocomplete="tel"')
    end

    it 'flags the links opening a new window in their text (RGAA 13.2)' do
      expect(response.body).to include('INSEE<span class="fr-sr-only"> - nouvelle fenêtre</span>')
    end

    it 'does not use the common header nor the stepper' do
      expect(response.body).not_to include('fr-stepper')
    end

    it 'shows the request number and its status as small grey tags' do
      page = Capybara.string(response.body)

      expect(page).to have_css('#wallet-header-badges .fr-badge.fr-badge--sm', text: "demande #{authorization_request.formatted_id}")
      expect(page).to have_css('#wallet-header-badges .fr-badge.fr-badge--sm.fr-badge--grey', text: 'Brouillon')
    end

    it 'shows a decorative pictogram left of the title, hidden from screen readers' do
      head = Capybara.string(response.body).find('.wx-head__row')

      expect(head).to have_css('.wx-head__picto + .wx-head__id h1')
      expect(head).to have_css('.wx-head__picto img[alt=""][aria-hidden="true"][src*="registre_wallet/pictogramme-en-tete"]', visible: :all)
    end

    it 'puts « Enregistrer » before « Supprimer »' do
      actions = Capybara.string(response.body).all('.wx-head__actions .fr-btn').map { |button| button.text.strip }

      expect(actions).to eq(%w[Enregistrer Supprimer])
    end

    it 'goes back to the introduction with « Précédent »' do
      expect(Capybara.string(response.body)).to have_link('Précédent', href: authorization_request_form_introduction_path(form_uid: 'registre-wallet'))
    end
  end

  describe 'GET the step while Sirene did not answer' do
    let(:organization) { create(:organization, siret: '21920023500022').tap { |org| org.update!(insee_payload: nil, insee_consecutive_failures: 1) } }
    let(:page) { Capybara.string(response.body) }

    before { get step_path }

    it 'announces that a successful retrieval is needed before submitting, with a button to retry it' do
      alert = page.find('.fr-alert--warning', text: 'Le répertoire Sirene ne répond pas')

      expect(alert).to have_text('vous ne pourrez la soumettre qu’après une récupération réussie')
      expect(alert).to have_button('Relancer la récupération', id: 'wallet-identity-refresh')
      expect(page.find_button('Relancer la récupération')['form']).to eq('wallet-identity-refresh-form')
    end

    it 'does not open any manual entry of the identity' do
      expect(page).to have_no_field(type: 'file')
      expect(response.body).not_to include("#{param_key}_wallet_postal_address", "#{param_key}_wallet_legal_name", "#{param_key}_wallet_address_proof")
    end

    it 'keeps a single retry button' do
      expect(page).to have_css('#wallet-identity-refresh', count: 1)
    end
  end

  describe 'clicking « Suivant » on an empty step' do
    before { patch step_path, params: { next: '', param_key => { wallet_website_url: '' } } }

    it 'stays on the step with the error summary linked to each field' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('3 points à corriger avant de continuer', "href=\"##{param_key}_wallet_privacy_policy_url\"", "href=\"##{param_key}_wallet_support_url\"")
    end

    it 'does not repeat the errors in a flash message' do
      expect(response.body).not_to include('Nous n’avons pas pu sauvegarder votre demande')
    end
  end

  describe 'clicking « Enregistrer » on an incomplete step' do
    before { patch step_path, params: { save: '', param_key => { wallet_website_url: 'https://www.clamart.fr' } } }

    it 'saves the draft without error' do
      expect(response).to redirect_to(step_path)
      expect(authorization_request.reload.wallet_website_url).to eq('https://www.clamart.fr')
    end
  end

  describe 'clicking « Enregistrer » with a badly formatted value' do
    before do
      patch step_path, params: { save: '', param_key => { wallet_website_url: 'http://www.clamart.fr', wallet_support_email: 'contact@clamart.fr' } }
    end

    it 'saves the other values and sets the badly formatted one aside' do
      authorization_request.reload

      expect([authorization_request.wallet_support_email, authorization_request.wallet_website_url]).to eq(['contact@clamart.fr', nil])
    end

    it 'shows the step again with the typed value and its message, as a form error Turbo renders' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('value="http://www.clamart.fr"', 'Brouillon enregistré, sauf une valeur au format invalide : Site internet de l’organisation', 'Indiquez une adresse qui commence par https://')
    end
  end

  describe 'the deletion modal' do
    before { get new_authorization_request_archive_path(authorization_request) }

    it 'puts « Supprimer la demande » first, so that it is shown on the right after « Annuler », without icon' do
      buttons = Capybara.string(response.body).all('.fr-modal__footer .fr-btn')

      expect(buttons.map { |button| button.text.strip }).to eq(['Supprimer la demande', 'Annuler'])
      expect(buttons.first[:class]).not_to include('fr-icon')
    end
  end

  describe 'deleting the draft' do
    subject(:archive) { post authorization_request_archive_index_path(authorization_request) }

    before do
      create(:authorization_request_event, :create, authorization_request:)
    end

    it 'archives the draft and keeps it with all its events' do
      events = AuthorizationRequestEvent.where(authorization_request:)
      names_before = events.pluck(:name)

      archive

      expect(authorization_request.reload).to be_archived
      expect(events.pluck(:name)).to match_array(names_before + ['archive'])
    end

    it 'goes back to the introduction with the success message' do
      archive

      expect(response).to redirect_to(authorization_request_form_introduction_path(form_uid: 'registre-wallet'))
      follow_redirect!
      expect(response.body).to include('La demande « Enregistrement d’une partie utilisatrice » a été supprimée avec succès')
    end
  end
end
