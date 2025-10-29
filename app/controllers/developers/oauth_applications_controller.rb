class Developers::OauthApplicationsController < DevelopersController
  def index
    @applications = Doorkeeper::Application.where(owner: current_user)
  end
end
