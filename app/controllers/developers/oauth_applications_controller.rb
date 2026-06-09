class Developers::OauthApplicationsController < DevelopersController
  before_action :set_application, only: :destroy

  def index
    authorize Doorkeeper::Application, policy_class: Developer::OauthApplicationPolicy
    @applications = policy_scope(Doorkeeper::Application, policy_scope_class: Developer::OauthApplicationPolicy::Scope)
  end

  def new
    authorize Doorkeeper::Application, :create?, policy_class: Developer::OauthApplicationPolicy
    @application = Doorkeeper::Application.new
  end

  def create
    authorize Doorkeeper::Application, :create?, policy_class: Developer::OauthApplicationPolicy
    @application = Doorkeeper::Application.new(
      application_params.merge(owner: current_user, scopes: read_only_scopes)
    )

    if @application.save
      success_message(title: t('.success'))
      redirect_to developers_oauth_applications_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    authorize @application, policy_class: Developer::OauthApplicationPolicy
    @application.destroy!
    success_message(title: t('.success'))
    redirect_to developers_oauth_applications_path
  end

  private

  def set_application
    @application = policy_scope(Doorkeeper::Application, policy_scope_class: Developer::OauthApplicationPolicy::Scope).find(params.expect(:id))
  end

  def application_params
    params.expect(doorkeeper_application: [:name])
  end

  def read_only_scopes
    Doorkeeper.configuration.default_scopes.to_s
  end
end
