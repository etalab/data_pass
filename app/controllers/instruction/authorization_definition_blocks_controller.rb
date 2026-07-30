class Instruction::AuthorizationDefinitionBlocksController < Instruction::FormManagementController
  before_action :set_authorization_definition

  def show
    authorize [:instruction, @authorization_definition], :show?

    @default_form = @authorization_definition.default_form
    @static_block_names = @default_form.static_blocks.to_set { |b| b[:name].to_s }
    @authorization_request = build_preview_request(@default_form)
    @preview_organization = preview_organization
  end

  private

  def set_authorization_definition
    @authorization_definition = AuthorizationDefinition.find(params.expect(:authorization_definition_id))
  end
end
