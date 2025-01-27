class API::V1::CredentialsController < API::V1Controller
  def me
    render json: current_user.attributes.slice('id', 'email', 'family_name', 'given_name', 'job_title')
  end
end
