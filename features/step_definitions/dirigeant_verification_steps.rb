def mock_proconnect_dirigeant(user, acr: OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE, sub: user.external_id, email: user.email, siret: user.current_organization.siret)
  OmniAuth.config.mock_auth[:proconnect_dirigeant] = OmniAuth::AuthHash.new(
    provider: :proconnect_dirigeant,
    uid: sub,
    info: { email: },
    extra: {
      acr:,
      amr: %w[pwd mfa],
      raw_info: { sub:, email:, siret: }
    }
  )
end

Sachantque('ProConnect certifie que je suis dirigeant de mon organisation') do
  mock_proconnect_dirigeant(current_user!)
end

Sachantque('ProConnect ne certifie pas mon statut de dirigeant') do
  mock_proconnect_dirigeant(current_user!, acr: 'eidas1-mfa')
end

Sachantque('ProConnect certifie un autre compte comme dirigeant') do
  mock_proconnect_dirigeant(current_user!, sub: 'autre-sub', email: 'autre-dirigeant@example.fr')
end

Sachantque('ProConnect certifie que je suis dirigeant d’une autre entreprise') do
  mock_proconnect_dirigeant(current_user!, siret: '13002526500013')
end

Sachantque('je suis dirigeant d’une entreprise privée') do
  @current_user_email = 'dirigeant@entreprise.fr'
  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email, skip_organization_creation: true)
  company = Organization.find_by(legal_entity_id: '32816124500027') || FactoryBot.create(:organization, siret: '32816124500027')

  add_current_organization_to_user(user, company)

  mock_identity_federators(user)
end

Quand('je me rends sur la page de vérification de dirigeant') do
  visit dirigeant_verification_path
end

After do
  OmniAuth.config.mock_auth[:proconnect_dirigeant] = nil
end
