class DashboardController < AuthenticatedUserController
  def index
    redirect_to dashboard_show_path(id: 'moi')
  end

  def show
    case params[:id]
    when 'moi'
      @authorization_requests = policy_scope(AuthorizationRequest).where(applicant: current_user)
    when 'organisation'
      @authorization_requests = policy_scope(AuthorizationRequest)
    when 'mentions'
      @authorization_requests = AuthorizationRequestsMentionsQuery.new(current_user).perform
    else
      redirect_to dashboard_show_path(id: 'moi')
    end

    @authorization_requests = @authorization_requests.not_archived.eager_load(:latest_authorization)
  end

  private

  def layout_name
    'dashboard'
  end
end
