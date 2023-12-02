module SessionsHelpers
  def sign_in(user)
    page.set_rack_session(user_id: {
      'value' => user.id,
      'expires_at' => 9001.hours.from_now
    })
  end
end
