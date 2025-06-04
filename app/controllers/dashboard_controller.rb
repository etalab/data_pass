class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

  decorates_assigned :authorization_requests

  def index
    redirect_to dashboard_show_path(id: 'demandes')
  end

  def show
    @tabs = [
      Tab.new('demandes', dashboard_show_path(id: 'demandes', **request.query_parameters)),
      Tab.new('habilitations', dashboard_show_path(id: 'habilitations', **request.query_parameters)),
    ]

    case params[:id]
    when 'demandes'
      @items = policy_scope(base_relation).not_archived.order(created_at: :desc)
      @highlighted_categories = {
        changes_requested: @items.changes_requested,
      }
      @categories = {
        pending: @items.in_instructions,
        draft: @items.drafts,
        validated_or_refused: @items.validated_or_refused,
      }
    when 'habilitations'
      @items = current_user.authorizations_as_applicant.order(created_at: :desc)
      @highlighted_categories = {}
      @categories = {
        active: @items.where(state: :active),
        revoked: @items.where(state: :revoked),
      }
    end
  end

  private

  class Tab < Data.define(:id, :path)
  end

  def dashboard_v1
    case params[:id]
    when 'demandes'
      @items = policy_scope(AuthorizationRequest)
      @authorization_requests = AuthorizationRequest.none
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

    @authorization_requests = @authorization_requests.not_archived.order(created_at: :desc)

    # render :show_v1, layout: 'dashboard'
  end

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

  # def layout_name
  #   'dashboard'
  # end
end
