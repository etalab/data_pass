class DashboardHabilitationsFacade < AbstractDashboardFacade
  def data
    builder = search_builder
    grouped = builder.build_relation(scoped_relation).to_a.group_by(&:state)

    {
      highlighted_categories: {},
      categories: {
        active: grouped.fetch('active', []),
        revoked: grouped.fetch('revoked', []),
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
