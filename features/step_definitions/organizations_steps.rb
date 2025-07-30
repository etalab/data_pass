Sachantque("je suis rattaché à l'organisation {string}") do |organization_name|
  @current_user_email = 'demandeur@gouv.fr'

  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)
  organization = find_or_create_organization_by_name(organization_name)

  user.add_to_organization(organization, verified: true)
end
