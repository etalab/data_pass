class APIController < ActionController::API
  include Authentication

  api_mode!

  def user_id_session
    {
      'value' => doorkeeper_token.try(:application).try(:owner),
      'expires_at' => (doorkeeper_token.try(:expires_in) || 0) + Time.current.to_i,
    }
  end
end
