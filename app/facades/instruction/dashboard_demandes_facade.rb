class Instruction::DashboardDemandesFacade < Instruction::DashboardFacade
  private

  def build_facade
    super
    @unread_from_applicant_count_by_id = AuthorizationRequest.unread_messages_from_applicant_counts_for(@items)
  end

  def partial_name
    'authorization_requests'
  end
end
