RSpec.describe 'Wallet registry, step « Les contacts »' do
  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:user) { create(:user, given_name: 'Camille', family_name: 'Martin', email: 'camille.martin@clamart.fr').tap { |applicant| applicant.add_to_organization(organization, current: true) } }
  let(:authorization_request) do
    create(:authorization_request, :registre_wallet, applicant: user, organization:, fill_all_attributes: true).tap do |request|
      request.update!(contacts.transform_values { nil })
    end
  end
  let(:step_path) { authorization_request_form_build_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id, id: 'contacts-de-l-organisation') }
  let(:param_key) { authorization_request.model_name.param_key }
  let(:contact_attributes) { %w[family_name given_name email phone_number] }
  let(:contacts) do
    {
      wallet_application_manager: %w[Martin Camille camille.martin@clamart.fr 0472000000],
      wallet_technical_contact: ['Lefèvre', 'Jules', 'jules.lefevre@clamart.fr', '+33 (0)4 72 00 00 01'],
      wallet_data_protection_officer: %w[Durand Alex dpo@clamart.fr 04.72.00.00.02],
    }.each_with_object({}) do |(type, values), attributes|
      contact_attributes.zip(values).each { |attribute, value| attributes[:"#{type}_#{attribute}"] = value }
    end
  end

  before { sign_in(user) }

  def click(button, fields)
    patch step_path, params: { button => '', param_key => fields }
  end

  def its_me_buttons
    response.parsed_body.css('[data-wallet-contacts-target="itsMe"]')
  end

  describe 'GET the step' do
    before { get step_path }

    it 'asks for the three contacts and says they are not published (RG5, CA4)' do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Étape 4/4', 'Qui pouvons-nous contacter dans votre organisation ?', 'Elles ne sont pas publiées')
      expect(response.body).to include('Responsable de l’application', 'Contact technique', 'Délégué à la protection des données (DPO)')
      expect(response.body).not_to match(/contact registre|suppression des données/i)
    end

    it 'groups each contact in a titled fieldset (CA5)' do
      expect(response.body).to include('aria-labelledby="wallet-contact-wallet_technical_contact-title"', 'aria-describedby="wallet-contact-wallet_technical_contact-info"')
    end

    it 'fills no contact and offers « C’est moi » on the three blocks (RG7)' do
      expect(its_me_buttons.size).to eq(3)
      expect(its_me_buttons.none? { |button| button['hidden'] }).to be true
      expect(response.body).not_to include('value="camille.martin@clamart.fr"')
    end
  end

  describe 'GET the step once the applicant is the technical contact' do
    before do
      get step_path
      applicant = user.reload
      authorization_request.update!(wallet_technical_contact_given_name: applicant.given_name, wallet_technical_contact_family_name: applicant.family_name, wallet_technical_contact_email: applicant.email)
      get step_path
    end

    it 'keeps « C’est moi » on that block only (CA2)' do
      visible = its_me_buttons.reject { |button| button['hidden'] }

      expect(visible.map { |button| button.ancestors('[data-contact-type]').first['data-contact-type'] }).to eq(['wallet_technical_contact'])
    end
  end

  describe 'clicking « Suivant » on an empty step' do
    before { click(:next, contacts.transform_values { '' }) }

    it 'stays on the step with the twelve points to fix (CA3)' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('12 points à corriger avant de continuer', "href=\"##{param_key}_wallet_application_manager_family_name\"", 'Indiquez le téléphone du délégué à la protection des données.')
    end
  end

  describe 'clicking « Suivant » with a badly formatted email and phone number (CA3)' do
    before { click(:next, contacts.merge(wallet_technical_contact_email: 'jules.lefevre@', wallet_data_protection_officer_phone_number: '04 72')) }

    it 'names the contact in the summary and explains the format under the field' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Contact technique : adresse électronique non valide', 'Délégué à la protection des données (DPO) : numéro de téléphone non valide')
      expect(response.body).to include('Indiquez une adresse électronique valide, par exemple nom@domaine.fr', 'Indiquez un numéro de téléphone valide, par exemple 04 72 00 00 00')
      expect(response.body).to include("#{param_key}_wallet_technical_contact_email-messages")
    end
  end

  describe 'clicking « Enregistrer » with an incomplete step (RG8)' do
    before { click(:save, wallet_technical_contact_family_name: 'Lefèvre') }

    it 'keeps what was typed in the draft' do
      expect(authorization_request.reload.wallet_technical_contact_family_name).to eq('Lefèvre')
    end
  end

  describe 'clicking « Suivant » with the three contacts filled (CA1)' do
    before { click(:next, contacts) }

    it 'saves them in the draft and shows them in the summary' do
      expect(response).to have_http_status(:redirect)
      expect(authorization_request.reload.data.slice(*contacts.keys.map(&:to_s)).values).to eq(contacts.values)

      follow_redirect! while response.redirect?
      expect(response.body).to include('Les contacts de l’organisation', 'Ces contacts ne sont pas publiés.', 'Jules Lefèvre', 'dpo@clamart.fr')
    end
  end
end
