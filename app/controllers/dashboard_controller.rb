class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

  def index
    redirect_to dashboard_show_path(id: 'moi')
  end

  def show # rubocop:disable Metrics/AbcSize
    case params[:id]
    when 'moi'
      @authorization_requests = policy_scope(base_relation).where(applicant: current_user)
    when 'organisation'
      @authorization_requests = policy_scope(base_relation)
    when 'mentions'
      @authorization_requests = AuthorizationRequestsMentionsQuery.new(current_user).perform(authorization_requests_relation)
    else
      redirect_to dashboard_show_path(id: 'moi')
      return
    end

    @authorization_requests = @authorization_requests.not_archived.order(created_at: :desc).includes(:authorizations)
  end

  private

  def authorization_requests_relation
    if registered_subdomain?
      base_relation.where(type: registered_subdomain.authorization_request_types)
    else
      base_relation.all
    end
  end

  def base_relation
    AuthorizationRequest
      .joins('left join authorizations on authorizations.request_id = authorization_requests.id')
      .select('authorization_requests.*, count(authorizations.id) as authorizations_count')
      .group('authorization_requests.id')
  end

  def layout_name
    'dashboard'
  end
end
