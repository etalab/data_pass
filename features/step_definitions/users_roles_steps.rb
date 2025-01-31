Quand("il y a l'utilisateur {string} avec le rôle {string} pour {string}") do |email, humanized_role, authorization_definition_name|
  user = User.find_by(email:) || FactoryBot.create(:user, email: email)

  case humanized_role.downcase
  when 'instructeur'
    role = 'instructor'
  when 'rapporteur'
    role = 'reporter'
  when 'développeur'
    role = 'developer'
  else
    raise "Unknown role #{humanized_role}"
  end

  user.roles << "#{find_factory_trait_from_name(authorization_definition_name)}:#{role}"
  user.roles.uniq!
  user.save!
end

Quand("il y a l'utilisateur {string} avec le rôle d'administrateur") do |email|
  user = User.find_by(email:) || FactoryBot.create(:user, email: email)

  user.roles << 'admin'
  user.roles.uniq!
  user.save!
end

Quand("il y a l'utilisateur {string} sans rôle") do |email|
  user = User.find_by(email:) || FactoryBot.create(:user, email: email)

  user.roles = []
  user.save!
end
