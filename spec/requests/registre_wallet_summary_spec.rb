RSpec.describe 'Wallet registry, summary and submission' do
  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:user) { create(:user, given_name: 'Camille', family_name: 'Martin', email: 'camille.martin@clamart.fr').tap { |applicant| applicant.add_to_organization(organization, current: true) } }
  let(:authorization_request) { create(:authorization_request, :registre_wallet, :draft, applicant: user, organization:, fill_all_attributes: true) }
  let(:summary_path) { summary_authorization_request_form_path(form_uid: 'registre-wallet', id: authorization_request.id) }
  let(:submit_path) { authorization_request_form_path(form_uid: 'registre-wallet', id: authorization_request.id) }
  let(:param_key) { authorization_request.model_name.param_key }
  let(:both_consents) { { wallet_registration_policy_accepted: '1', wallet_information_certified: '1' } }
  let(:page) { response.parsed_body }

  before { sign_in(user) }

  def submit(consents)
    patch submit_path, params: { submit: '', param_key => consents }
  end

  describe 'GET the summary' do
    before { get summary_path }

    it 'asks to check the request before submitting it, within the registry delay (R1)' do
      expect(page.at_css('h2').text).to eq('Vérifiez votre demande avant de la soumettre')
      expect(response.body).to include('Le registre vérifie ensuite votre organisation sous 5 jours ouvrés.')
      expect(page.css('.fr-alert--warning')).to be_empty
    end

    it 'shows neither the generic applicant and organization banner nor the draft save time (R2, R9)' do
      expect(response.body).not_to include('Ces informations ne sont pas modifiables', 'Brouillon enregistré')
    end

    it 'opens the contacts with the applicant (R3)' do
      cards = page.css("##{ActionView::RecordIdentifier.dom_id(authorization_request, :wallet_contacts)} .contact-card__kind").map(&:text)

      expect(cards).to eq(['Demandeur', 'Responsable de l’application', 'Contact technique', 'Délégué à la protection des données (DPO)'])
      applicant_card = page.at_css("##{ActionView::RecordIdentifier.dom_id(authorization_request, :wallet_applicant)}").text.squish

      expect(applicant_card).to include("#{user.reload.given_name.capitalize} #{user.family_name.capitalize}", 'Agent de la commune, connecté par ProConnect', 'camille.martin@clamart.fr')
    end

    it 'names the registry submission and leaves the boxes to the server (R10, R11)' do
      expect(page.at_css('#submit_authorization_request').text).to eq('Soumettre la demande d’enregistrement')
      expect(page.at_css("form##{ActionView::RecordIdentifier.dom_id(authorization_request)}")['novalidate']).to be_present
    end
  end

  describe 'submit without the two boxes' do
    before { submit(wallet_registration_policy_accepted: '1', wallet_information_certified: '0') }

    it 'keeps the draft and asks to check both boxes on the page (R11)' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(authorization_request.reload).to be_draft
      expect(page.at_css('#wallet-consents-messages').text).to include('Cochez les deux cases pour soumettre votre demande.')
      expect(page.css('#wallet-incomplete-steps')).to be_empty
    end
  end

  describe 'submit with an incomplete step' do
    before do
      authorization_request.update_columns(data: authorization_request.data.merge('wallet_service_description' => '', 'wallet_technical_contact_email' => ''))
      submit(both_consents)
    end

    it 'links to each incomplete step, in order' do
      links = page.css('#wallet-incomplete-steps a').map(&:text)

      expect(response).to have_http_status(:unprocessable_content)
      expect(links).to eq(['Corriger l’étape 2 : le service', 'Corriger l’étape 4 : les contacts'])
    end
  end

  describe 'submit while the public sector of the organization is still unknown' do
    before do
      authorization_request.update_columns(data: authorization_request.data.merge('identity_public_sector' => nil))
      submit(both_consents)
    end

    it 'keeps the draft and asks to retrieve the organization again (4 ter)' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(authorization_request.reload).to be_draft
      expect(page.at_css('#wallet-incomplete-steps').text).to include('Corriger l’étape 1 : l’organisation', 'Relancez la récupération depuis l’étape « L’organisation »')
    end
  end

  describe 'submit while the organization identity is still loading' do
    before do
      authorization_request.update_columns(data: authorization_request.data.merge('identity_source' => 'sirene_pending', 'identity_public_sector' => nil))
      submit(both_consents)
    end

    it 'gives a single reason, the loading one, under the step « L’organisation »' do
      incomplete_steps = page.at_css('#wallet-incomplete-steps').text

      expect(incomplete_steps).to include('Corriger l’étape 1 : l’organisation', 'en cours de chargement')
      expect(incomplete_steps).not_to include('Relancez la récupération')
    end
  end

  describe 'submit a complete request' do
    before { submit(both_consents) }

    it 'sends it to verification and tells what comes next (T1)' do
      expect(response).to redirect_to(dashboard_path)
      expect(authorization_request.reload).to be_submitted

      follow_redirect! while response.redirect?

      expect(response.body).to include("La demande d’enregistrement de #{authorization_request.wallet_service_name} a été soumise avec succès", 'Le registre la vérifie sous 5 jours ouvrés.')
    end
  end

  describe 'GET a submitted request' do
    before do
      authorization_request.update!(state: 'submitted')
      get summary_path
    end

    it 'shows it read only, without wizard step nor draft wording (T3)' do
      expect(response.body).not_to include('Étape 1/4', 'Brouillon enregistré', 'Vérifiez ses informations', 'Vérifiez votre demande avant de la soumettre')
      expect(page.css('#submit_authorization_request')).to be_empty
    end
  end
end
