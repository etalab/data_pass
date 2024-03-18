def mock_mon_compte_pro(user)
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
end

Sachantque('je suis un demandeur') do
  @current_user_email = 'demandeur@gouv.fr'
  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)

  mock_mon_compte_pro(user)
end

Sachantque('je consulte le site ayant le sous-domaine {string}') do |subdomain|
  Capybara.app_host = "http://#{subdomain}.localtest.me"
end

Sachantque('je suis un instructeur {string}') do |kind|
  user = create_instructor(kind)

  if @current_user_email.blank?
    @current_user_email = user.email
    mock_mon_compte_pro(user)
  end

  if @current_user_email != user.email
    current_user.roles << "#{find_factory_trait_from_name(kind)}:instructor"
    current_user.roles.uniq!
    current_user.save!
  end
end

Sachantque('je me connecte') do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "S’identifier avec MonComptePro"
  )
end
