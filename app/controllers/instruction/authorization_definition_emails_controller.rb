class Instruction::AuthorizationDefinitionEmailsController < Instruction::FormManagementController
  before_action :set_authorization_definition

  def index
    authorize [:instruction, @authorization_definition], :show?
    @can_edit = policy([:instruction, @authorization_definition]).edit?
    @automated_email_previews = @authorization_definition.automated_emails.map do |automated_email|
      AutomatedEmailPreview.for(@authorization_definition, automated_email)
    end
  end

  private

  def set_authorization_definition
    @authorization_definition = AuthorizationDefinition.find(params.expect(:authorization_definition_id))
  end
end
