class DashboardController < AuthenticatedUserController
  def index
    redirect_to dashboard_show_path(id: 'demandes')
  end

  def show
    @facade = DashboardFacade.new(current_user, params, request)
    @tabs = @facade.tabs

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
    data = @facade.demandes_data(method(:policy_scope))
    @highlighted_categories = data[:highlighted_categories]
    @categories = data[:categories]
    @search_engine = data[:search_engine]
  end

  def handle_habilitations_tab
    data = @facade.habilitations_data(method(:policy_scope))
    @highlighted_categories = data[:highlighted_categories]
    @categories = data[:categories]
    @search_engine = data[:search_engine]
  end
end
