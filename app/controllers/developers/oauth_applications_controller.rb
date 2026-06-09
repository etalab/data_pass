class Developers::OauthApplicationsController < DevelopersController
  before_action :set_application, only: %i[destroy show_credentials]

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
      flash[:show_credentials] = true
      redirect_to show_credentials_developers_oauth_application_path(@application)
    else
      render :new, status: :unprocessable_content
    end
  end

  def show_credentials
    authorize @application, policy_class: Developer::OauthApplicationPolicy

    redirect_to developers_oauth_applications_path unless flash[:show_credentials]
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

  def model_to_track_for_impersonation
    @application
  end
end
