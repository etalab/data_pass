class DashboardDemandesFacade < AbstractDashboardFacade
  def data
    builder = search_builder
    grouped = builder.build_relation(scoped_relation).to_a.group_by(&:state)

    {
      highlighted_categories: {
        changes_requested: grouped.fetch('changes_requested', []),
      },
      categories: {
        pending: grouped.fetch('submitted', []),
        draft: grouped.fetch('draft', []),
        refused: grouped.fetch('refused', []),
      },
      search_engine: builder.search_engine
    }
  end

  def model_class
    AuthorizationRequest
  end

  def displayed_states
    %w[draft submitted refused changes_requested]
  end

  def tab_type
    'demandes'
  end
end
