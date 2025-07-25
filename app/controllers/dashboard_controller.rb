class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

  Tab = Data.define(:id, :path, :count)

  def index
    redirect_to dashboard_show_path(id: 'demandes')
  end

  def show
    case params[:id]
    when 'demandes'
      search_object = Search::DashboardDemandesSearch.new(
        user: current_user,
        params: params,
        subdomain_types: current_subdomain_types,
        scope: policy_scope(AuthorizationRequest)
      )
      @facade = DashboardDemandesFacade.new(search_object: search_object)
    when 'habilitations'
      search_object = Search::DashboardHabilitationsSearch.new(
        user: current_user,
        params: params,
        subdomain_types: current_subdomain_types,
        scope: policy_scope(Authorization)
      )
      @facade = DashboardHabilitationsFacade.new(search_object: search_object)
    else
      redirect_to(dashboard_show_path(id: 'demandes')) and return
    end
    
    # Maintain backward compatibility for templates
    @categories = @facade.categories
    @highlighted_categories = @facade.highlighted_categories
    @search_engine = @facade.search_engine
  end

  private

  def query_parameters
    request.query_parameters
  end

  def current_subdomain_types
    return unless registered_subdomain?

    registered_subdomain.authorization_request_types
  end
end
