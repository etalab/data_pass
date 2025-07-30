def mock_identity_federators(user)
  mock_proconnect(user)
  mock_mon_compte_pro(user)
end

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

def mock_proconnect(user, identity_provider_uid: '71144ab3-ee1a-4401-b7b3-79b44f7daeeb', siret: nil)
  proconnect_omniauth_payload = build(
    :proconnect_omniauth_payload,
    data_identity_id: identity_provider_uid,
    siret: siret || user.current_organization.siret,
    extra: {
      'raw_info' => attributes_for(
        :proconnect_raw_info_payload,
        email: user.email,
        sub: user.external_id,
        idp_id: identity_provider_uid
      )
    }
  )

  OmniAuth.config.mock_auth[:proconnect] = OmniAuth::AuthHash.new(
    {
      provider: :proconnect,
    }.merge(proconnect_omniauth_payload)
  )

  stub_request(:get, "#{Rails.application.credentials.proconnect_url}/.well-known/openid-configuration")
end

Sachantque('je suis un demandeur') do
  @current_user_email = 'demandeur@gouv.fr'
  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)

  mock_identity_federators(user)
end

Sachantque('je suis un demandeur d\'une organisation fermée') do
  @current_user_email = 'demandeur@gouv.fr'
  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)

  closed_organization = Organization.find_by(siret: '21920023500022') || FactoryBot.create(:organization, siret: '21920023500022')

  closed_organization.users << user
  user.current_organization = closed_organization
  user.save!

  mock_identity_federators(user)
end

Sachantque("je suis un demandeur pour l'organisation {string}") do |organization_name|
  @current_user_email = 'demandeur@gouv.fr'
  organization = find_or_create_organization_by_name(organization_name)
  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email, current_organization: organization)

  add_current_organization_to_user(user, organization)

  user.save!

  mock_identity_federators(user)
end

Sachantque('je consulte le site ayant le sous-domaine {string}') do |subdomain|
  $previous_app_host = Capybara.app_host.dup
  Capybara.app_host = "http://#{subdomain}.localtest.me"
end

Sachantque('je suis un instructeur {string}') do |kind|
  user = create_instructor(kind)

  if @current_user_email.blank?
    @current_user_email = user.email
    mock_identity_federators(user)
  end

  if @current_user_email != user.email
    current_user.roles << "#{find_factory_trait_from_name(kind)}:instructor"
    current_user.roles.uniq!
    current_user.save!
  end
end

Sachantque('je suis un rapporteur {string}') do |kind|
  user = create_reporter(kind)

  if @current_user_email.blank?
    @current_user_email = user.email
    mock_identity_federators(user)
  end

  if @current_user_email != user.email
    current_user.roles << "#{find_factory_trait_from_name(kind)}:reporter"
    current_user.roles.uniq!
    current_user.save!
  end
end

Sachantque('je suis un développeur {string}') do |kind|
  user = create_reporter(kind)

  if @current_user_email.blank?
    @current_user_email = user.email
    mock_identity_federators(user)
  end

  current_user.roles << "#{find_factory_trait_from_name(kind)}:reporter" if @current_user_email != user.email
  current_user.roles << "#{find_factory_trait_from_name(kind)}:developer"
  current_user.roles.uniq!
  current_user.save!

  Doorkeeper::Application.create!(
    name: 'Accès API Entreprise',
    uid: 'client_id',
    secret: 'so_secret',
    owner: user,
  )
end

Sachantque('je suis un administrateur') do
  user = create_admin

  if @current_user_email.blank?
    @current_user_email = user.email
    mock_identity_federators(user)
  end

  if @current_user_email != user.email
    current_user.roles << 'admin'
    current_user.roles.uniq!
    current_user.save!
  end
end

Sachantque('je me connecte') do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "S’identifier avec ProConnect"
  )
end

Sachantque('je me connecte via ProConnect') do
  steps %(
    Quand je me rends sur le chemin "proconnect-connexion"
    Et que je clique sur "S’identifier avec ProConnect"
  )
end

Sachantque("je me connecte via ProConnect avec l'identité {string}") do |identity_provider_name|
  @current_user_email = 'demandeur@gouv.fr'

  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)
  identity_provider = IdentityProvider.where(name: identity_provider_name).first

  mock_proconnect(user, identity_provider_uid: identity_provider.id)

  steps %(
    Quand je me rends sur le chemin "proconnect-connexion"
    Et que je clique sur "S’identifier avec ProConnect"
  )
end

Sachantque("je me connecte via ProConnect avec l'identité {string} qui renvoi l'organisation {string}") do |identity_provider_name, organization_name|
  @current_user_email = 'demandeur@gouv.fr'

  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)
  identity_provider = IdentityProvider.where(name: identity_provider_name).first

  organization = find_or_create_organization_by_name(organization_name)

  mock_proconnect(user, identity_provider_uid: identity_provider.id, siret: organization.siret)

  steps %(
    Quand je me rends sur le chemin "proconnect-connexion"
    Et que je clique sur "S’identifier avec ProConnect"
  )
end
