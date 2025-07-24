class DashboardDemandesFacade < DashboardFacade
  def categories
    {
      pending: filtered_results.in_instructions,
      draft: filtered_results.drafts,
      refused: filtered_results.refused,
    }
  end

  def highlighted_categories
    {
      changes_requested: filtered_results.changes_requested,
    }
  end

  private

  def partial_name
    'authorization_requests'
  end

  def demandes_count
    search_object.count
  end

  def habilitations_count
    # Calculate habilitations count for the same user/filters
    habilitations_search = Search::DashboardHabilitationsSearch.new(
      user: search_object.user,
      params: search_object.send(:params),
      subdomain_types: search_object.subdomain_types,
      scope: Authorization.all
    )
    habilitations_search.count
  end

  def filtered_results
    search_object.results
  end
end
