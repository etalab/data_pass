class DashboardDemandesFacade < AbstractDashboardFacade
  def data
    builder = search_builder
    relation = builder.build_relation(scoped_relation.where(state: displayed_states))
    requests_by_state = relation.to_a.group_by(&:state)

    {
      highlighted_categories: {
        changes_requested: requests_by_state.fetch('changes_requested', []),
      },
      categories: {
        pending: requests_by_state.fetch('submitted', []),
        draft: requests_by_state.fetch('draft', []),
        refused: requests_by_state.fetch('refused', []),
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
