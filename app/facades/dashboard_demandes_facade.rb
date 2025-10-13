class DashboardDemandesFacade < AbstractDashboardFacade
  def data
    builder = search_builder
    demandes = builder.build_authorization_requests_relation(scoped_relation)

    {
      highlighted_categories: {
        changes_requested: demandes.changes_requested,
      },
      categories: {
        pending: demandes.in_instructions,
        draft: demandes.drafts,
        refused: demandes.refused,
      },
      search_engine: builder.search_engine
    }
  end

  def model_class
    AuthorizationRequest
  end
end
