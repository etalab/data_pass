class DashboardHabilitationsFacade < DashboardFacade
  def categories
    {
      active: filtered_results.where(state: :active),
      revoked: filtered_results.where(state: :revoked),
    }
  end

  def highlighted_categories
    {}
  end

  private

  def partial_name
    'authorizations'
  end

  def demandes_count
    # Calculate demandes count for the same user/filters
    demandes_search = Search::DashboardDemandesSearch.new(
      user: search_object.user,
      params: search_object.send(:params),
      subdomain_types: search_object.subdomain_types,
      scope: AuthorizationRequest.all
    )
    demandes_search.count
  end

  def habilitations_count
    search_object.count
  end

  def filtered_results
    search_object.results
  end
end
