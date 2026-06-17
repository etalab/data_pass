Sachantque('il existe un token de désinscription valide pour cet instructeur') do
  user = User.find_by(email: @current_user_email)
  definition = AuthorizationDefinition.find('api_entreprise')
  @unsubscribe_token = NotificationUnsubscribeToken.generate(
    user:,
    definition_id: definition.id,
    kind: 'submit',
  )
end

Sachantque('il existe un token de désinscription expiré pour cet instructeur') do
  user = User.find_by(email: @current_user_email)
  definition = AuthorizationDefinition.find('api_entreprise')
  travel_to((NotificationUnsubscribeToken::EXPIRES_IN + 1.day).ago) do
    @unsubscribe_token = NotificationUnsubscribeToken.generate(
      user:,
      definition_id: definition.id,
      kind: 'submit',
    )
  end
end

Sachantque('cet instructeur a perdu son rôle sur API Entreprise') do
  user = User.find_by(email: @current_user_email)
  user.update!(roles: [])
end

Quand('je me rends sur la page de désinscription avec ce token') do
  visit notification_unsubscriptions_path(token: @unsubscribe_token)
end

Alors('la préférence de notification n’a pas changé') do
  user = User.find_by(email: @current_user_email)
  expect(user.instruction_submit_notifications_for_api_entreprise).to be_truthy
end

Alors('la notification de soumission est désactivée pour cet instructeur') do
  user = User.find_by(email: @current_user_email)
  expect(user.reload.instruction_submit_notifications_for_api_entreprise).to be(false)
end
