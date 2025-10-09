class Instruction::MessageTemplatesController < InstructionController
  before_action :set_message_template, only: %i[edit update destroy preview]
  before_action :extract_managed_authorization_definition_uids, only: %i[index new create edit update]

  def index
    authorize [:instruction, MessageTemplate]

    @message_templates = policy_scope([:instruction, MessageTemplate]).order(created_at: :desc)
  end

  def new
    @message_template = MessageTemplate.new
    authorize [:instruction, @message_template]
  end

  def create
    @message_template = MessageTemplate.new(message_template_params)
    authorize [:instruction, @message_template]

    if @message_template.save
      success_message(title: t('.success'))

      redirect_to instruction_message_templates_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize [:instruction, @message_template]
  end

  def update
    authorize [:instruction, @message_template]

    if @message_template.update(message_template_params)
      success_message(title: t('.success'))

      redirect_to instruction_message_templates_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize [:instruction, @message_template]

    @message_template.destroy!
    success_message(title: t('.success'))
    redirect_to instruction_message_templates_path
  end

  def preview
    authorize [:instruction, @message_template]

    @authorization_request = @message_template.authorization_definition.authorization_request_class.new(id: -1)
    interpolator = MessageTemplateInterpolator.new(@message_template.content)
    @preview_content = interpolator.interpolate(@authorization_request)

    render :preview
  end

  private

  def set_message_template
    @message_template = MessageTemplate.find(params[:id])
  end

  def extract_managed_authorization_definition_uids
    @managed_authorization_definition_uids = managed_authorization_definition_uids
  end

  def managed_authorization_definition_uids
    current_user.manager_roles.map { |role| role.split(':').first }
  end

  def managed_authorization_definitions
    AuthorizationDefinition.where(
      id: managed_authorization_definition_uids
    ).select { |ad| ad.feature?(:message_templates) }
  end

  def message_template_params
    params.expect(
      message_template: %i[
        authorization_definition_uid
        template_type
        title
        content
      ]
    )
  end
end
