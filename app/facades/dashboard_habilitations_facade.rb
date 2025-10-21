class DashboardHabilitationsFacade < AbstractDashboardFacade
  def data
    builder = search_builder
    habilitations = builder.build_authorizations_relation(scoped_relation)

    {
      highlighted_categories: {},
      categories: {
        active: habilitations.where(state: :active),
        revoked: habilitations.where(state: :revoked),
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
end
