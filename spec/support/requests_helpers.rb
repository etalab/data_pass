module RequestsHelpers
  # rubocop:disable Metrics/AbcSize
  def sign_in(user)
    OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new({
      provider: :mon_compte_pro,
      uid: user.external_id,
      info: attributes_for(:mon_compte_pro_payload, email: user.email, external_id: user.external_id, siret: user.current_organization.siret),
      credentials: {
        token: 'token',
        expires_at: 1.hour.from_now.to_i,
        expires: true
      }
    })

    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:mon_compte_pro]

    get '/auth/mon_compte_pro/callback'
  end
  # rubocop:enable Metrics/AbcSize
end
