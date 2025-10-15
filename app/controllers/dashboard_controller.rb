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
      build_facade_for(DashboardDemandesFacade, AuthorizationRequest)
    when 'habilitations'
      build_facade_for(DashboardHabilitationsFacade, Authorization)
    else
      redirect_to(dashboard_show_path(id: 'demandes'))
    end
  end

  def build_facade_for(facade_class, scoped_model)
    facade_class.new(
      user: current_user,
      search_query: params[:search_query],
      subdomain_types: current_subdomain_types,
      scoped_relation: policy_scope(scoped_model)
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
