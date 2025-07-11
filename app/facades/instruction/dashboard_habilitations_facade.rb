class Instruction::DashboardHabilitationsFacade < Instruction::DashboardFacade
  private

  def partial_name
    'authorizations'
  end

  def demandes_count
    0
  end

  def habilitations_count
    search_object.count
  end
end
