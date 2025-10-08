class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

  Tab = Data.define(:id, :path)

  def index
    redirect_to dashboard_show_path(id: 'demandes')
  end

  def show
    @facade = DashboardFacade.new(current_user, params[:search_query], subdomain_types: current_subdomain_types)
    @tabs = build_tabs

    case params[:id]
    when 'demandes'
      handle_demandes_tab
    when 'habilitations'
      handle_habilitations_tab
    else
      redirect_to(dashboard_show_path(id: 'demandes')) and return
    end
  end

  private

  def handle_demandes_tab
    data = @facade.demandes_data(policy_scope(AuthorizationRequest))
    @highlighted_categories = data[:highlighted_categories]
    @categories = data[:categories]
    @search_engine = data[:search_engine]
    @show_filters = @facade.show_demandes_filters?(policy_scope(AuthorizationRequest))
  end

  def handle_habilitations_tab
    data = @facade.habilitations_data(policy_scope(Authorization))
    @highlighted_categories = data[:highlighted_categories]
    @categories = data[:categories]
    @search_engine = data[:search_engine]
    @show_filters = @facade.show_habilitations_filters?(policy_scope(Authorization))
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
