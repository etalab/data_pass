class API::V1::CredentialsController < APIController
  before_action :doorkeeper_authorize!

  def me
    render json: current_user.attributes.slice('id', 'email', 'family_name', 'given_name', 'job_title')
  end
end
