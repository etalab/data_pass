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

Sachantque('je suis un instructeur {string}') do |kind|
  @current_user_email = "#{kind.parameterize}@gouv.fr"
  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)

  user.roles << "#{find_form_from_name(kind).authorization_request_class.to_s.underscore.split('/').last}:instructor"
  user.roles.uniq!
  user.save!

  OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new({
    provider: :mon_compte_pro,
    uid: user.external_id,
    info: attributes_for(:mon_compte_pro_payload, email: @current_user_email, external_id: user.external_id),
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
