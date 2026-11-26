RSpec.describe 'Sign in through the ProConnect dirigeant journey' do
  let(:organization) { create(:organization, siret:) }
  let(:siret) { '32816124500027' }
  let(:user) { create(:user, skip_organization_creation: true) }

  before do
    user.add_to_organization(organization, current: true, verified: true)
    OmniAuth.config.mock_auth[:proconnect] = OmniAuth::AuthHash.new(
      build(
        :proconnect_omniauth_payload,
        data_identity_id: IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID,
        siret:,
        extra: {
          'raw_info' => attributes_for(
            :proconnect_raw_info_payload,
            email: user.email,
            sub: user.external_id,
            siret:,
            idp_id: IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID
          ),
          'acr' => 'eidas1-mfa'
        }
      )
    )
  end

  after { OmniAuth.config.mock_auth[:proconnect] = nil }

  def sign_in_as_dirigeant
    post '/auth/proconnect', params: { parcours: 'dirigeant' }
    follow_redirect!
  end

  it 'signs the user in then chains the dirigeant certification for the same SIRET' do
    sign_in_as_dirigeant

    expect(session[:user_id]).to be_present
    expect(response).to redirect_to("/auth/proconnect_dirigeant?siret_hint=#{siret}")
  end

  it 'carries the return_to through the chained dirigeant certification' do
    post '/auth/proconnect', params: { parcours: 'dirigeant', return_to: '/demandes/registre/nouveau' }
    follow_redirect!
    follow_redirect!
    follow_redirect!

    expect(response).to redirect_to('/demandes/registre/nouveau')
  end

  it 'lets the chained request start without a form' do
    sign_in_as_dirigeant
    follow_redirect!

    expect(response).to redirect_to(%r{/auth/proconnect_dirigeant/callback})
  end

  it 'does not start the chained certification once the chain has expired' do
    sign_in_as_dirigeant

    travel_to(3.minutes.from_now) { follow_redirect! }

    expect(response).to have_http_status(:not_found)
  end

  it 'does not start the dirigeant certification by GET outside the chain' do
    get '/auth/proconnect_dirigeant'

    expect(response).to have_http_status(:not_found)
  end

  context 'when the dirigeant certification is abandoned after the sign in' do
    before do
      sign_in_as_dirigeant
      get dirigeant_verification_path
    end

    it 'keeps the user signed in' do
      expect(session[:user_id]).to be_present
    end

    it 'does not certify the user as dirigeant' do
      expect(response.body).not_to include('ProConnect certifie que vous êtes dirigeant')
    end

    it 'still asks the user to run the certification' do
      expect(response.body).to include('id="verify_dirigeant"')
    end
  end

  context 'when the organization belongs to the public sector' do
    let(:siret) { '21920023500014' }

    before { sign_in_as_dirigeant }

    it 'keeps the user signed in' do
      expect(session[:user_id]).to be_present
    end

    it 'sends the user back to the verification page without starting the certification' do
      expect(response).to redirect_to(dirigeant_verification_path)
    end

    it 'links back to the page given as return_to' do
      post '/auth/proconnect', params: { parcours: 'dirigeant', return_to: '/demandes/registre/nouveau' }
      follow_redirect!
      follow_redirect!

      expect(response.body).to include('id="back_to_return_to" href="/demandes/registre/nouveau"')
    end

    it 'explains that the certification is reserved to private companies' do
      follow_redirect!

      expect(response.body).to include('Votre organisation relève du secteur public')
      expect(response.body).not_to include('id="verify_dirigeant"')
    end
  end
end
