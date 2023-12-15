Sachantque('je suis un demandeur') do
  OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new({
    provider: :mon_compte_pro,
    uid: '1',
    info: attributes_for(:mon_compte_pro_payload),
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
