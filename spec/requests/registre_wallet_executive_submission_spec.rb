RSpec.describe 'Wallet registry, submission by a certified executive' do
  let(:organization) { create(:organization, siret: '32816124500027') }
  let(:user) { create(:user).tap { |applicant| applicant.add_to_organization(organization, current: true) } }
  let(:authorization_request) { create(:authorization_request, :registre_wallet, :draft, applicant: user, organization:, fill_all_attributes: true) }
  let(:summary_path) { summary_authorization_request_form_path(form_uid: 'registre-wallet', id: authorization_request.id) }
  let(:start_path) { wallet_registry_submission_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id) }
  let(:param_key) { authorization_request.model_name.param_key }
  let(:both_consents) { { wallet_registration_policy_accepted: '1', wallet_information_certified: '1' } }
  let(:dirigeant_payload) do
    OmniAuth::AuthHash.new(
      provider: :proconnect_dirigeant,
      uid: user.external_id,
      info: { email: user.email },
      extra: {
        acr: OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE,
        raw_info: { sub: user.external_id, siret: organization.siret }
      }
    )
  end

  before do
    OmniAuth.config.mock_auth[:proconnect_dirigeant] = dirigeant_payload
    sign_in(user)
  end

  after { OmniAuth.config.mock_auth[:proconnect_dirigeant] = nil }

  def start_submission(consents = both_consents)
    post start_path, params: { param_key => consents }
    follow_redirect! if response.redirect?
  end

  def page
    response.parsed_body
  end

  def return_path
    page.at_css('input[name=return_to]')['value']
  end

  def come_back_from_pro_connect(path = return_path)
    post '/auth/proconnect_dirigeant', params: { return_to: path, origin: path }
    follow_redirect!
    follow_redirect!
  end

  it 'offers to reconnect before submitting, with the reason (RG4)' do
    get summary_path

    expect(page.at_css('#submit_authorization_request').text).to eq('Se reconnecter et soumettre')
    expect(page.at_css('#wallet-executive-reconnection').text).to include('vous vous reconnecterez avec ProConnect')
  end

  it 'lets Turbo send the button, with the page token rather than the token of the summary form' do
    get summary_path

    expect(page.at_css('#submit_authorization_request')['data-turbo']).to be_nil
  end

  context 'with forgery protection, as in production' do
    around do |example|
      ActionController::Base.allow_forgery_protection = true
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = false
    end

    it 'accepts the button sent by Turbo to another address than the summary form' do
      get summary_path
      post start_path, params: { param_key => both_consents }, headers: { 'X-CSRF-Token' => page.at_css('meta[name=csrf-token]')['content'] }

      expect(response).to redirect_to(reconnect_wallet_registry_submission_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id))
    end
  end

  it 'sends back to the summary a reconnection page opened without a submission in progress' do
    get reconnect_wallet_registry_submission_path(form_uid: 'registre-wallet', authorization_request_id: authorization_request.id)

    expect(response).to redirect_to(summary_path)
  end

  it 'refuses the classic submission, which would skip the reconnection' do
    patch authorization_request_form_path(form_uid: 'registre-wallet', id: authorization_request.id), params: { submit: '', param_key => both_consents }

    expect(authorization_request.reload).to be_draft
  end

  context 'when the request is complete' do
    before { start_submission }

    it 'keeps the draft and sends the executive to ProConnect' do
      expect(response).to have_http_status(:ok)
      expect(authorization_request.reload).to be_draft
      expect(authorization_request.wallet_information_certified).to be true
      expect(page.at_css('form[action="/auth/proconnect_dirigeant"]')).to be_present
    end

    it 'submits the request when ProConnect certifies the executive again' do
      come_back_from_pro_connect

      expect(response).to redirect_to(dashboard_path)
      expect(authorization_request.reload).to be_submitted
    end

    it 'focuses the refusal on the way back from ProConnect' do
      dirigeant_payload.extra.acr = 'eidas1-mfa'
      come_back_from_pro_connect

      expect(page.css('[autofocus]').pluck('id')).to eq(['wallet-submission-refusal'])
    end

    it 'keeps the draft when ProConnect no longer certifies the executive (CA4)' do
      dirigeant_payload.extra.acr = 'eidas1-mfa'
      come_back_from_pro_connect

      expect(response).to have_http_status(:unprocessable_content)
      expect(authorization_request.reload).to be_draft
      expect(page.at_css('#wallet-submission-refusal').text).to include('Vous ne pouvez pas soumettre cette demande')
    end

    it 'does not submit twice with the same return link' do
      path = return_path
      come_back_from_pro_connect(path)

      expect { get path }.not_to(change { AuthorizationRequestEvent.where(name: 'submit', authorization_request:).count })
      expect(response).to have_http_status(:redirect).or have_http_status(:unprocessable_content)
    end

    it 'does not submit with a certification older than the click' do
      get '/auth/proconnect_dirigeant/callback'
      travel 1.minute do
        start_submission
        get return_path
      end

      expect(authorization_request.reload).to be_draft
      expect(page.at_css('#wallet-submission-refusal').text).to include('Vous ne pouvez pas soumettre cette demande')
    end
  end

  context 'when the reconnection fails or is cancelled at ProConnect (CA10)' do
    before do
      start_submission
      get '/auth/failure', params: { message: 'access_denied', strategy: 'proconnect_dirigeant', origin: return_path }
      follow_redirect!
    end

    it 'comes back to the summary with the draft kept' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(authorization_request.reload).to be_draft
      expect(page.at_css('#wallet-submission-refusal')).to be_present
    end
  end

  context 'when a step is incomplete' do
    before do
      authorization_request.update_columns(data: authorization_request.data.merge('wallet_service_description' => ''))
      start_submission
    end

    it 'lists the step without going to ProConnect (RG2)' do
      expect(response).to have_http_status(:unprocessable_content)
      expect(page.at_css('form[action="/auth/proconnect_dirigeant"]')).to be_nil
      expect(page.css('#wallet-incomplete-steps a').map(&:text)).to eq(['Corriger l’étape 2 : le service'])
    end
  end
end
