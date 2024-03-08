OmniAuth.config.test_mode = true

def current_user
  @current_user ||= User.find_by(email: @current_user_email)
end

def create_instructor(kind)
  email ||= "#{kind.parameterize}@gouv.fr"

  user = User.find_by(email:) || FactoryBot.create(:user, email:)

  user.roles << "#{find_factory_trait_from_name(kind)}:instructor"
  user.roles.uniq!
  user.save!

  user
end

After do
  OmniAuth.config.mock_auth[:mon_compte_pro] = nil
end
