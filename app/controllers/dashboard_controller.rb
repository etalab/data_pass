class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

  Tab = Data.define(:id, :path)

  def index
    redirect_to dashboard_show_path(id: default_tab)
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
      Tab.new('demandes', dashboard_show_path(id: 'demandes')),
      Tab.new('habilitations', dashboard_show_path(id: 'habilitations')),
    ]
  end

  def query_parameters
    request.query_parameters
  end

  def current_subdomain_types
    return unless registered_subdomain?

    registered_subdomain.authorization_request_types
  end

  def default_tab
    demandes_facade = build_unfiltered_facade(DashboardDemandesFacade, AuthorizationRequest)
    return 'demandes' if demandes_facade.any?

    habilitations_facade = build_unfiltered_facade(DashboardHabilitationsFacade, Authorization)
    return 'habilitations' if habilitations_facade.any?

    'demandes'
  end

  def build_unfiltered_facade(facade_class, scoped_model)
    facade_class.new(
      user: current_user,
      search_query: nil,
      subdomain_types: current_subdomain_types,
      scoped_relation: policy_scope(scoped_model)
    )
  end
end
