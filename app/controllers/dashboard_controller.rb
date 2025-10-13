class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

  Tab = Data.define(:id, :path)

  def index
    redirect_to dashboard_show_path(id: 'demandes')
  end

  def show
    @tabs = build_tabs
    @facade = build_facade
  end

  private

  def build_facade
    case params[:id]
    when 'demandes'
      build_demande_facade
    when 'habilitations'
      build_habilitation_facade
    else
      redirect_to(dashboard_show_path(id: 'demandes'))
    end
  end

  def build_demande_facade
    DashboardDemandesFacade.new(
      user: current_user,
      search_query: params[:search_query],
      subdomain_types: current_subdomain_types,
      scoped_relation: policy_scope(AuthorizationRequest)
    )
  end

  def build_habilitation_facade
    DashboardHabilitationsFacade.new(
      user: current_user,
      search_query: params[:search_query],
      subdomain_types: current_subdomain_types,
      scoped_relation: policy_scope(Authorization)
    )
  end

  def build_tabs
    [
      Tab.new('demandes', dashboard_show_path(id: 'demandes', **query_parameters)),
      Tab.new('habilitations', dashboard_show_path(id: 'habilitations', **query_parameters)),
    ]
  end

  def query_parameters
    request.query_parameters
  end

  def current_subdomain_types
    return unless registered_subdomain?

    registered_subdomain.authorization_request_types
  end
end
