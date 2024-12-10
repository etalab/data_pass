# rubocop:disable Metrics/AbcSize
def user_session(user)
  return user_sessions[user.email] if user_sessions[user.email].present?

  user_sessions[user.email] = Capybara::Session.new(Capybara.default_driver, Rails.application)

  Capybara.using_session(user_sessions[user.email]) do
    mock_mon_compte_pro(user)
    step 'je me connecte'
  end

  @user_sessions[user.email]
end
# rubocop:enable Metrics/AbcSize

def user_sessions
  @user_sessions ||= {}
end

def using_user_session(user, &)
  Capybara.using_session(user_session(user), &)
end

def using_last_applicant_session(&)
  using_user_session(AuthorizationRequest.last.applicant, &)
end
