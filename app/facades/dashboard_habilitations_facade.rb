class DashboardHabilitationsFacade < AbstractDashboardFacade
  def data
    builder = search_builder
    relation = builder.build_relation(scoped_relation.where(state: displayed_states))
    authorizations_by_state = relation.to_a.group_by(&:state)

    {
      highlighted_categories: {},
      categories: {
        active: authorizations_by_state.fetch('active', []),
        revoked: authorizations_by_state.fetch('revoked', []),
      },
      search_engine: builder.search_engine
    }
  end

  def model_class
    Authorization
  end

  def displayed_states
    %w[active revoked]
  end

  def tab_type
    'habilitations'
  end
end
