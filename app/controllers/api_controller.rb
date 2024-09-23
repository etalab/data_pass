class APIController < ActionController::API
  include Authentication

  api_mode!

  def user_id_session
    {
      'value' => doorkeeper_token.resource_owner_id,
      'expires_at' => doorkeeper_token.expires_in + Time.current.to_i,
    }
  end
end
