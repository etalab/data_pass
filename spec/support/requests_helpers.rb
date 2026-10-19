module RequestsHelpers
  def sign_in(user)
    OmniAuth.config.mock_auth[:proconnect] = OmniAuth::AuthHash.new(
      build(
        :proconnect_omniauth_payload,
        data_identity_id: IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID,
        siret: user.current_organization.siret,
        extra: {
          'raw_info' => attributes_for(
            :proconnect_raw_info_payload,
            email: user.email,
            sub: user.external_id,
            idp_id: IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID
          ),
          'acr' => 'eidas1-mfa'
        }
      )
    )

    get '/auth/proconnect/callback'
  end
end

shared_examples 'an unauthorized access' do
  it do
    subject

    # rubocop:disable-next Lint/SuppressedException
    begin
      5.times { follow_redirect! }
    rescue RuntimeError
    end

    expect(response.request.path).to match('/tableau-de-bord')
    expect(response.body).to include('pas le droit')
  end
end
