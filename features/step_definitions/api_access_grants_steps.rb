Sachantque('le fournisseur de données de la définition {string} s’appelle {string}') do |definition_id, name|
  slug = AuthorizationDefinition.find(definition_id).provider_slug
  data_provider = DataProvider.find_by(slug:) || FactoryBot.build(:data_provider, slug:)
  data_provider.update!(name:)
end

Sachantque('qu’une application OAuth {string} dont le propriétaire est développeur sur {string} existe') do |name, definition_id|
  owner = FactoryBot.create(:user, :developer, email: 'dev-test@gouv.fr', authorization_request_types: [definition_id])
  @api_application = FactoryBot.create(:oauth_application, name:, owner:)
end

Sachantque('qu’un droit de soumission est accordé à {string} pour {string}') do |application_name, data_provider_name|
  APIAccessGrant.create!(
    oauth_application: Doorkeeper::Application.find_by!(name: application_name),
    data_provider: DataProvider.find_by!(name: data_provider_name),
    action: 'submission',
    grant_reason: 'Parcours qualifié',
    granted_by_email: 'admin@gouv.fr'
  )
end

Sachantque('le fournisseur de données {string} n’est plus référencé par aucune définition') do |name|
  DataProvider.find_by!(name:).update!(slug: 'fournisseur-sans-definition')
  AuthorizationDefinition.reset!
end

Alors('la liste {string} propose {string}') do |name, option|
  expect(find(:select, name)).to have_selector(:option, option)
end

Alors('la liste {string} ne propose pas {string}') do |name, option|
  expect(find(:select, name)).to have_no_selector(:option, option)
end
