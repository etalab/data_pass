class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

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
      @authorization_requests = AuthorizationRequestsMentionsQuery.new(current_user).perform(authorization_requests_relation)
    else
      redirect_to dashboard_show_path(id: 'moi')
      return
    end

    @authorization_requests = @authorization_requests.not_archived.order(created_at: :desc)
  end

  private

  def authorization_requests_relation
    if registered_subdomain?
      AuthorizationRequest.where(type: registered_subdomain.authorization_request_types)
    else
      AuthorizationRequest.all
    end
  end

  def layout_name
    'dashboard'
  end
end
