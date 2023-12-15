OmniAuth.config.test_mode = true

def current_user
  @current_user ||= User.find_by(email: @current_user_email)
end

After do
  OmniAuth.config.mock_auth[:mon_compte_pro] = nil
end
