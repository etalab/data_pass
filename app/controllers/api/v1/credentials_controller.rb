class API::V1::CredentialsController < API::V1Controller
  before_action -> { doorkeeper_authorize! }, only: %i[me]

  def me
    render json: current_user.attributes.slice('id', 'email', 'family_name', 'given_name', 'job_title')
  end
end
