Sachantque('je suis un demandeur') do
  @current_user_email = 'demandeur@gouv.fr'

  OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new({
    provider: :mon_compte_pro,
    uid: '1',
    info: attributes_for(:mon_compte_pro_payload, email: @current_user_email),
    credentials: {
      token: 'token',
      expires_at: 1.hour.from_now.to_i,
      expires: true
    }
  })
end

Sachantque('je me connecte') do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "S'identifier avec MonComptePro"
  )
end
