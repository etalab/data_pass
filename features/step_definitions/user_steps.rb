Sachantque("l'utilisateur {string} est banni") do |email|
  user = User.find_by!(email:)
  user.update!(banned_at: Time.zone.now, ban_reason: 'Compte compromis')
end

Quand("l'utilisateur {string} est banni par un admin") do |email|
  user = User.find_by!(email:)
  admin = User.find_by(email: 'admin@gouv.fr') || create_admin
  Admin::BanUser.call(user_email: user.email, ban_reason: 'Compte compromis', admin:)
end

Sachantque('il existe un utilisateur ayant l\'email {string}') do |email|
  @user = FactoryBot.create(:user, email: email)
end

Sachantque('il existe un utilisateur {string} appartenant à l\'organisation {string}') do |email, siret|
  organization = Organization.find_by(legal_entity_id: siret, legal_entity_registry: 'insee_sirene')
  organization ||= FactoryBot.create(:organization, legal_entity_id: siret, legal_entity_registry: 'insee_sirene')

  @target_applicant = FactoryBot.create(:user, email: email, current_organization: organization)
end
