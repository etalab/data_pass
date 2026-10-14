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

  def failed_context
    Interactor::Context.build.tap do |context|
      context.fail!(error: { key: :something_else })
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
end
