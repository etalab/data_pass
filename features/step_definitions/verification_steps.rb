Sachantque('je suis un vérificateur du registre wallet') do
  user = FactoryBot.create(:user, :wallet_verifier, email: 'verificateur@gouv.fr')

  @current_user_email = user.email
  mock_identity_federators(user)
end

Quand('mon rôle de vérificateur est retiré') do
  current_user!.update!(roles: [])
end
