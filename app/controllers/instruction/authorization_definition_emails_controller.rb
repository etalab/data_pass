class Instruction::AuthorizationDefinitionEmailsController < Instruction::FormManagementController
  before_action :set_authorization_definition

  def index
    authorize [:instruction, @authorization_definition], :show?
    @can_edit = policy([:instruction, @authorization_definition]).edit?
  end

  private

  def set_authorization_definition
    @authorization_definition = AuthorizationDefinition.find(params.expect(:authorization_definition_id))
  end
end
