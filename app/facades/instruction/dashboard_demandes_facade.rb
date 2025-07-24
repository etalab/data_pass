class Instruction::DashboardDemandesFacade < Instruction::DashboardFacade
  private

  def partial_name
    'authorization_requests'
  end

  def demandes_count
    search_object.count
  end

  def habilitations_count
    0
  end
end
