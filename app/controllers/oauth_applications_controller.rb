class OauthApplicationsController < AuthenticatedUserController
  def index
    @applications = Doorkeeper::Application.where(owner: current_user)
  end
end
