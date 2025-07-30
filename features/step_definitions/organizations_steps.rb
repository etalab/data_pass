Sachantque("je suis rattaché à l'organisation {string}") do |organization_name|
  @current_user_email = 'demandeur@gouv.fr'

  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)
  organization = find_or_create_organization_by_name(organization_name)

  user.add_to_organization(organization, verified: true)
end

Alors("l'organisation associée est marquée comme {string}") do |kind|
  user = User.find_by(email: @current_user_email)

  case kind
  when 'vérifiée'
    expect(user.current_organization_user.verified).to be true
  when 'non vérifiée'
    expect(user.current_organization_user.verified).to be false
  when 'ajoutée manuellement'
    expect(user.current_organization_user.manual).to be true
  when 'ajoutée automatiquement'
    expect(user.current_organization_user.manual).to be false
  else
    raise "Unknown attribute kind to test: #{kind}"
  end
end
