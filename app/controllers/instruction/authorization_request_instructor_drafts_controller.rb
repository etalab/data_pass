class Instruction::AuthorizationRequestInstructorDraftsController < InstructionController
  helper AuthorizationRequestsHelpers

  layout 'application'

  before_action :authorize_instructor

  def index
    @authorization_request_instructor_drafts = policy_scope([:instruction, AuthorizationRequestInstructorDraft]).includes(:instructor, :applicant, :organization)

    render 'index', layout: 'container'
  end

  def new
    authorization_definition = extract_authorization_definition_from_context

    if authorization_definition.nil?
      @definitions = current_user.instructor_roles.map do |scope|
        authorization_definition_id = scope.split(':').first
        AuthorizationDefinition.find(authorization_definition_id)
      end

      render 'select_definition', layout: 'container'
    else
      @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.new(authorization_request_class: authorization_definition.authorization_request_class.to_s)

      prepare_request

      render 'edit'
    end
  end

  def create
    organizer = CreateAuthorizationRequestInstructorDraft.call(
      authorization_request_params:,
      authorization_request_instructor_draft_params: {
        authorization_request_class: 'AuthorizationRequest::APIEntreprise',
      },
      instructor: current_user,
    )

    @authorization_request_instructor_draft = organizer.authorization_request_instructor_draft
    prepare_request

    if organizer.success?
      success_message(title: t('.success'))

      redirect_to edit_instruction_authorization_request_instructor_draft_path(@authorization_request_instructor_draft),
        status: :see_other
    else
      error_message(title: t('.error'))

      render 'edit', status: :unprocessable_entity
    end
  end

  def show
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.find(params[:id])
    authorize [:instruction, @authorization_request_instructor_draft]

    prepare_request

    render 'edit'
  end

  def edit
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.find(params[:id])
    authorize [:instruction, @authorization_request_instructor_draft]

    prepare_request
  end

  def update
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.find(params[:id])
    authorize [:instruction, @authorization_request_instructor_draft]

    organizer = UpdateAuthorizationRequestInstructorDraft.call(
      authorization_request_instructor_draft: @authorization_request_instructor_draft,
      authorization_request_params:
    )

    prepare_request

    if organizer.success?
      success_message(title: t('.success'))

      redirect_to edit_instruction_authorization_request_instructor_draft_path(@authorization_request_instructor_draft),
        status: :see_other
    else
      error_message(title: t('.error'))

      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.find(params[:id])
    authorize [:instruction, @authorization_request_instructor_draft]

    @authorization_request_instructor_draft.destroy

    success_message(title: t('.success'))

    redirect_to instruction_authorization_request_instructor_drafts_path,
      status: :see_other
  end

  private

  def extract_authorization_definition_from_context
    if params[:authorization_definition_id].present?
      AuthorizationDefinition.find(params[:authorization_definition_id])
    elsif current_user.instructor_roles.one?
      scope = current_user.instructor_roles.first
      authorization_definition_id = scope.split(':').first

      AuthorizationDefinition.find(authorization_definition_id)
    end
  end

  def authorization_request_params
    params.require(authorization_request_class.model_name.singular)
  rescue ActionController::ParameterMissing
    ActionController::Parameters.new
  end

  def prepare_request
    @authorization_request = @authorization_request_instructor_draft.request.decorate
  end

  def authorization_request_class
    AuthorizationRequest::APIEntreprise
  end

  def model_to_track_for_impersonation
    @authorization_request_instructor_draft
  end

  def authorize_instructor
    authorize %i[instruction authorization_request_instructor_draft], :enable?
  end
end
