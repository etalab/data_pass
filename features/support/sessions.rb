OmniAuth.config.test_mode = true

OmniAuth.config.before_callback_phase do |env|
  if (id_token = env['omniauth.auth']&.dig('credentials', 'id_token'))
    env['rack.session']['omniauth.pc.id_token'] = id_token
  end
end

def current_user
  if instance_variable_defined?(:@current_user)
    @current_user
  else
    @current_user = User.find_by(email: @current_user_email)
  end
end

def create_admin
  email = 'admin@gouv.fr'
  user = User.find_by(email:) || FactoryBot.create(:user, email:)

  user.roles << 'admin'
  user.roles.uniq!
  user.save!

  user
end

def create_instructor(kind)
  create_user_with_role(:instructor, kind)
end

def create_reporter(kind)
  create_user_with_role(:reporter, kind)
end

def create_manager(kind)
  create_user_with_role(:manager, kind)
end

def create_user_with_role(role, kind)
  email ||= "#{kind.parameterize}@gouv.fr"

  user = User.find_by(email:) || FactoryBot.create(:user, email:)

  user.roles << "#{find_factory_trait_from_name(kind)}:#{role}"
  user.roles.uniq!
  user.save!

  user
end

After do
  OmniAuth.config.mock_auth[:mon_compte_pro] = nil
end
