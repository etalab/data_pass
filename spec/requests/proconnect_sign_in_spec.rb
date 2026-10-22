RSpec.describe 'ProConnect sign-in' do
  let(:sub) { 'sub-already-known' }
  let!(:previous_account) { create(:user, email: 'old-address@example.com', external_id: sub) }
  let(:payload) do
    build(:proconnect_omniauth_payload, siret: '21920023500014').tap do |omniauth_payload|
      omniauth_payload['extra']['raw_info']['email'] = 'new-address@example.com'
      omniauth_payload['extra']['raw_info']['sub'] = sub
    end
  end

  before do
    OmniAuth.config.mock_auth[:proconnect] = OmniAuth::AuthHash.new(payload)
  end

  def failed_context(error: { key: :something_else })
    Interactor::Context.build.tap do |context|
      context.fail!(error:)
    rescue Interactor::Failure
      nil
    end
  end

  after { OmniAuth.config.mock_auth[:proconnect] = nil }

  it 'redirects to the home page with an error when the sub belongs to an account with another email' do
    get '/auth/proconnect/callback'

    expect(response).to redirect_to(root_path)
    expect(flash[:error]['title']).to include('déjà associé à une autre adresse e-mail')
  end

  it 'redirects to the home page with a generic error for any other failure' do
    failed_result = failed_context
    allow(AuthenticateUserThroughProConnect).to receive(:call).and_return(failed_result)

    get '/auth/proconnect/callback'

    expect(response).to redirect_to(root_path)
    expect(flash[:error]['title']).to eq('La connexion a échoué. Veuillez réessayer.')
  end

  it 'redirects to the home page with a generic error when the error is a bare symbol, as with an unknown SIRET' do
    allow(AuthenticateUserThroughProConnect).to receive(:call).and_return(failed_context(error: :insee_entity_not_found))

    get '/auth/proconnect/callback'

    expect(response).to redirect_to(root_path)
    expect(flash[:error]['title']).to eq('La connexion a échoué. Veuillez réessayer.')
  end

  it 'reports the failure to Sentry with the error key' do
    allow(Sentry).to receive(:capture_message)

    get '/auth/proconnect/callback'

    expect(Sentry).to have_received(:capture_message).with(
      'Authentication failed',
      level: :warning,
      extra: { identity_federator: 'proconnect', error: hash_including(key: :user_email_mismatch) }
    )
  end

  it 'reports the error key of any other failure to Sentry' do
    allow(Sentry).to receive(:capture_message)
    allow(AuthenticateUserThroughProConnect).to receive(:call).and_return(failed_context)

    get '/auth/proconnect/callback'

    expect(Sentry).to have_received(:capture_message).with(
      'Authentication failed',
      level: :warning,
      extra: { identity_federator: 'proconnect', error: { key: :something_else } }
    )
  end
end
