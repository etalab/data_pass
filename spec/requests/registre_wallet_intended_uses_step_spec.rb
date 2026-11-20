RSpec.describe 'Wallet registry, step « Les utilisations prévues »' do
  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:user) { create(:user).tap { |applicant| applicant.add_to_organization(organization, current: true) } }
  let(:authorization_request) { create(:authorization_request, :registre_wallet, applicant: user, organization:, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }
  let(:pid) { WalletRegistry::Rulebook.available.find_by!(identifier: 'pid') }
  let(:mdl) { WalletRegistry::Rulebook.available.find_by!(identifier: 'mdl') }
  let(:param_key) { authorization_request.model_name.param_key }
  let(:step_path) { authorization_request_form_build_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id, id: 'utilisations-prevues') }
  let(:command_path) { authorization_request_form_wallet_intended_uses_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id) }

  before { sign_in(user) }

  def stored_uses
    WalletRegistry::IntendedUse.where(authorization_request_id: authorization_request.id).order(:id).to_a
  end

  def attestation_params(claim_ids)
    attestation = use.attestations.first

    { '0' => { 'id' => attestation.id.to_s, 'selected_claim_ids' => claim_ids || ['', *attestation.selected_claim_ids.map(&:to_s)] } }
  end

  def use_params(attributes = {}, claim_ids: nil)
    fields = { 'id' => use.id.to_s, 'name' => use.name, 'purpose' => use.purpose, 'start_date' => use.start_date.iso8601 }

    { '0' => fields.merge('requested_attestations_attributes' => attestation_params(claim_ids)).merge(attributes) }
  end

  def run_command(command, uses_params = use_params)
    patch command_path, params: { wallet_command: command, param_key => { wallet_intended_uses_attributes: uses_params } }
  end

  def add_account_use
    account = authorization_request.wallet_intended_uses.build(name: 'Ouvrir un compte client')
    account.add_attestation(pid)
    authorization_request.save!
    account
  end

  describe 'GET the step without any use' do
    before do
      authorization_request.wallet_intended_uses.destroy_all
      get step_path
    end

    it 'shows the empty state, the counter at zero and the button to add a use' do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Étape 3/3', 'Pourquoi demandez-vous des données aux usagers ?', 'Aucune utilisation prévue pour l’instant')
      expect(response.body).to include('soit <strong>0</strong>', 'Ajouter une utilisation prévue')
      expect(response.body).to include('Ajoutez une utilisation prévue pour voir l’aperçu.')
      expect(response.body).to match(%r{<h3 class="wx-preview-title[^"]*">Ce que verra l’usager</h3>})
      expect(response.body).not_to include('Utilisation prévue affichée')
    end
  end

  describe 'GET the step with one use' do
    before { get step_path }

    it 'shows the use, its attestation with the checked data, and no preview selector' do
      age_over_18 = mdl.claims.find_by!(identifier: 'age_over_18')

      expect(response.body).to include('Vérifier la majorité', 'Permis de conduire mobile · ', '1 donnée demandée', 'soit <strong>1</strong>')
      expect(response.body).to match(/value="#{age_over_18.id}"[^>]*checked="checked"/)
      expect(response.body).not_to include('Utilisation prévue affichée', 'Ajoutez une utilisation prévue pour voir l’aperçu.')
    end

    it 'links the preview to the privacy policy of the use' do
      expect(response.body).to include("href=\"#{use.effective_privacy_policy_url}\"", 'title="Politique de confidentialité - nouvelle fenêtre"')
    end

    it 'loads the catalog from its own address, and offers it without JavaScript' do
      expect(response.body).to include('Rechercher une attestation ou une donnée', 'Mon attestation n’est pas dans la liste')
      expect(response.body).to include("src=\"/formulaires/registre-wallet/demande/#{authorization_request.id}/utilisations-prevues/#{use.id}/attestations\"")
      expect(response.body).to include("value=\"open_catalog:#{use.id}\"")
      expect(response.body).not_to include("add_attestation:#{use.id}:#{pid.id}")
    end

    it 'asks a confirmation before removing an attestation or deleting the use' do
      expect(response.body).to include('Retirer l’attestation « Permis de conduire mobile » ?', 'La donnée cochée dans cette attestation sera aussi retirée de l’utilisation « Vérifier la majorité ».')
      expect(response.body).to include('Supprimer l’utilisation prévue « Vérifier la majorité » ?', 'Vous ne pourrez pas annuler cette suppression.')
    end
  end

  describe 'GET the step with two uses (CA2, CA9)' do
    let!(:account) { add_account_use }

    before { get step_path }

    it 'counts two registration certificates and offers the preview selector' do
      expect(response.body).to include('soit <strong>2</strong>', 'Utilisation prévue affichée', "<option value=\"#{account.id}\"")
    end
  end

  describe 'commands' do
    it 'adds a use, keeps what was typed, opens the new use and focuses its name' do
      run_command('add_use', use_params({ 'name' => 'Majorité' }))

      new_use = stored_uses.last
      expect(stored_uses.map(&:name)).to eq(['Majorité', nil])
      expect(response).to redirect_to(/utilisations-prevues\?focus=name&ouverte=#{new_use.id}#wallet-intended-uses/)
    end

    it 'removes a use and its rows' do
      run_command("remove_use:#{use.id}")

      expect(stored_uses).to be_empty
      expect(WalletRegistry::IntendedUseClaim.count).to eq(0)
      expect(response).to redirect_to(/focus=add_use/)
    end

    it 'adds an attestation, and focuses it' do
      run_command("add_attestation:#{use.id}:#{pid.id}")

      expect(stored_uses.first.attestations.map(&:rulebook)).to eq([mdl, pid])
      expect(response).to redirect_to(/focus=attestation_#{pid.id}&ouverte=#{use.id}/)
    end

    it 'reloads the step without error when another tab has just added the same attestation' do
      WalletRegistry::IntendedUseAttestation.create!(intended_use: use, rulebook: pid)
      allow_any_instance_of(WalletRegistry::IntendedUse).to receive(:attestation_for).and_return(nil) # rubocop:disable RSpec/AnyInstance

      run_command("add_attestation:#{use.id}:#{pid.id}")

      expect(response).to redirect_to(/ouverte=#{use.id}#wallet-intended-uses/)
      expect(stored_uses.first.attestations.map(&:rulebook)).to eq([mdl, pid])
    end

    it 'removes an attestation and its data, and focuses the button to add one' do
      run_command("remove_attestation:#{use.id}:#{mdl.id}")

      expect(stored_uses.first.credentials).to be_empty
      expect(response).to redirect_to(/focus=add_attestation&ouverte=#{use.id}/)
    end

    it 'saves the form, then opens the catalog page' do
      run_command("open_catalog:#{use.id}", use_params({ 'name' => 'Majorité' }))

      expect(stored_uses.first.name).to eq('Majorité')
      expect(response).to redirect_to("/formulaires/registre-wallet/demande/#{authorization_request.id}/utilisations-prevues/#{use.id}/attestations")
    end

    it 'runs without the fields of the form, from the catalog page' do
      patch command_path, params: { wallet_command: "add_attestation:#{use.id}:#{pid.id}" }

      expect(stored_uses.first.attestations.map(&:rulebook)).to eq([mdl, pid])
    end

    it 'records no event' do
      expect { run_command('add_use') }.not_to change(AuthorizationRequestEvent, :count)
    end

    it 'refuses an unknown command' do
      run_command("drop_everything:#{use.id}")

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'refuses a command on an unknown use' do
      run_command('remove_use:0')

      expect(response).to have_http_status(:unprocessable_content)
      expect(stored_uses.size).to eq(1)
    end

    context 'when the request belongs to someone else' do
      let(:authorization_request) { create(:authorization_request, :registre_wallet, organization:, fill_all_attributes: true) }

      it 'refuses the command without a flash' do
        patch command_path, params: { wallet_command: 'add_use' }

        expect(response).to have_http_status(:forbidden)
        expect(flash[:error]).to be_nil
      end
    end
  end

  describe 'a request of another form' do
    let(:other_request) { create(:authorization_request, :api_entreprise, applicant: user, organization:) }

    it 'has no step command nor catalog' do
      patch "/formulaires/api-entreprise/demande/#{other_request.id}/utilisations-prevues", params: { wallet_command: 'add_use' }
      expect(response).to have_http_status(:not_found)

      get "/formulaires/api-entreprise/demande/#{other_request.id}/utilisations-prevues/1/attestations"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'the catalog' do
    let(:catalog_path) { authorization_request_form_wallet_rulebooks_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id, intended_use_id: use.id) }

    it 'gives the results alone to the window of the step' do
      get catalog_path, headers: { 'Turbo-Frame' => "wallet-catalog-#{use.id}-results" }

      expect(response.body).to start_with("<turbo-frame id=\"wallet-catalog-#{use.id}-results\">")
      expect(response.body).to include('2 attestations dans le catalogue de la Commission', 'Déjà ajoutée', "value=\"add_attestation:#{use.id}:#{pid.id}\"", 'formaction=')
      expect(response.body).not_to include('<html')
    end

    it 'searches without accents, on the server' do
      get catalog_path, params: { q: 'identite' }, headers: { 'Turbo-Frame' => "wallet-catalog-#{use.id}-results" }

      expect(response.body).to include('1 attestation dans le catalogue de la Commission', 'Données d’identification personnelle (PID)')
      expect(response.body).not_to include('Permis de conduire mobile')
    end

    it 'says when nothing matches' do
      get catalog_path, params: { q: 'iban' }

      expect(response.body).to include('Aucune attestation ne correspond à votre recherche.')
    end

    it 'is a full page without JavaScript, with its own add buttons and a way back' do
      get catalog_path

      expect(response.body).to include('<html', 'Ajouter une attestation à l’utilisation prévue « Vérifier la majorité »', 'Revenir à l’utilisation prévue')
      expect(response.body).to include("name=\"wallet_command\" value=\"add_attestation:#{use.id}:#{pid.id}\"")
    end

    it 'hides the retired rulebooks' do
      pid.update!(retired_at: Time.current)
      get catalog_path

      expect(response.body).not_to include('Données d’identification personnelle (PID)')
    end

    it 'refuses a use of another request' do
      other_use = create(:authorization_request, :registre_wallet, applicant: user, organization:, fill_all_attributes: true).wallet_intended_uses.first
      get authorization_request_form_wallet_rulebooks_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id, intended_use_id: other_use.id)

      expect(response).to have_http_status(:not_found)
    end

    context 'when the request belongs to someone else' do
      let(:authorization_request) { create(:authorization_request, :registre_wallet, organization:, fill_all_attributes: true) }

      it 'refuses to show the catalog' do
        get catalog_path

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'clicking « Suivant » with an incomplete use (CA3)' do
    before do
      patch step_path, params: { next: '', param_key => { wallet_intended_uses_attributes: use_params({ 'purpose' => 'ok' }, claim_ids: ['']) } }
    end

    it 'stays on the step, with a summary linked to the fields' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('2 points à corriger avant de continuer')
      expect(response.body).to include('Vérifier la majorité : la finalité est trop courte.', "href=\"##{param_key}_wallet_intended_uses_attributes_0_purpose\"")
      expect(response.body).to include('Vérifier la majorité : cochez au moins une donnée dans « Permis de conduire mobile ».', "href=\"##{param_key}_wallet_intended_uses_attributes_0_attestation_#{mdl.id}\"")
    end

    it 'shows the message under the field, and keeps the unchecked box unchecked' do
      expect(response.body).to include("id=\"#{param_key}_wallet_intended_uses_attributes_0_purpose\"", 'Expliquez à l’usager pourquoi vous demandez ces données, en 15 caractères au moins')
      expect(response.body).to include('0 donnée demandée')
    end
  end

  describe 'clicking « Suivant » without any use' do
    before do
      authorization_request.wallet_intended_uses.destroy_all
      patch step_path, params: { next: '', param_key => { wallet_service_name: authorization_request.wallet_service_name } }
    end

    it 'asks for at least one use' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Ajoutez au moins une utilisation prévue.', 'href="#wallet-add-intended-use"')
    end
  end

  describe 'clicking « Suivant » with a complete use (CA1)' do
    before { patch step_path, params: { next: '', param_key => { wallet_intended_uses_attributes: use_params } } }

    it 'goes to the summary, which repeats the counter' do
      follow_redirect! while response.redirect?
      expect(response.body).to include('Les utilisations prévues des données', 'Vérifier la majorité', 'Plus de 18 ans', '1 certificat d’enregistrement')
      expect(response.body).to match(%r{contact-card__attribute-label[^>]*>Période</div>\s*<div class="contact-card__attribute-value})
      expect(response.body).to match(%r{contact-card__attribute-label[^>]*>Politique de confidentialité</div>})
    end
  end
end
