class APIController < ActionController::API
  include Authentication

  api_mode!

  def user_id_session
    {
      'value' => doorkeeper_token.try(:application).try(:owner),
      'expires_at' => (doorkeeper_token.try(:expires_in) || 0) + Time.current.to_i,
    }
  end

  private

  def current_user_authorization_request_types
    current_user.developer_roles.map do |role|
      "AuthorizationRequest::#{role.split(':')[0].classify}"
    end
  end

  def set_authorization_request
    @authorization_request = AuthorizationRequest
      .where(type: current_user_authorization_request_types)
      .find(params[:authorization_request_id] || params[:id])
  end
end
