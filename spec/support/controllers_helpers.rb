module ControllersHelpers
  def sign_in(user)
    session[:user_id] = {
      'value' => user.id,
      'expires_at' => 1.hour.from_now,
    }
  end
end
