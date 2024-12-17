class Instruction::InstructorDraftRequestsController < InstructionController
  helper AuthorizationRequestsHelpers

  layout 'application'

  before_action :authorize_instructor
  before_action :extract_available_definitions, only: %i[new]

  def index
    @instructor_draft_requests = policy_scope([:instruction, InstructorDraftRequest]).includes(:instructor, :applicant, :organization)

    render 'index', layout: 'container'
  end

  def new
    render layout: 'container'
  end

  def start
    authorization_request_form = AuthorizationRequestForm.find(params[:form_uid])
    @instructor_draft_request = InstructorDraftRequest.new(
      authorization_request_class: authorization_request_form.authorization_request_class.to_s,
      form_uid: authorization_request_form.uid,
      data: authorization_request_form.initialize_with
    )

    authorize [:instruction, @instructor_draft_request]

    prepare_request

    render 'edit'
  end

  def create
    organizer = CreateInstructorDraftRequest.call(
      authorization_request_params:,
      instructor_draft_request_params:,
      instructor: current_user,
    )

    @instructor_draft_request = organizer.instructor_draft_request

    if organizer.success?
      success_message(title: t('.success'))

      redirect_to edit_instruction_instructor_draft_request_path(@instructor_draft_request),
        status: :see_other
    else
      prepare_request
      error_message(title: t('.error'))

      render 'edit', status: :unprocessable_entity
    end
  end

  def edit
    @instructor_draft_request = InstructorDraftRequest.find(params[:id])
    authorize [:instruction, @instructor_draft_request]

    prepare_request
  end

  def update
    @instructor_draft_request = InstructorDraftRequest.find(params[:id])
    authorize [:instruction, @instructor_draft_request]

    organizer = UpdateInstructorDraftRequest.call(
      instructor_draft_request: @instructor_draft_request,
      authorization_request_params:
    )

    prepare_request

    if organizer.success?
      success_message(title: t('.success'))

      redirect_to edit_instruction_instructor_draft_request_path(@instructor_draft_request),
        status: :see_other
    else
      error_message(title: t('.error'))

      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @instructor_draft_request = InstructorDraftRequest.find(params[:id])
    authorize [:instruction, @instructor_draft_request]

    @instructor_draft_request.destroy

    success_message(title: t('.success'))

    redirect_to instruction_instructor_draft_requests_path,
      status: :see_other
  end

  private

  def extract_available_definitions
    @definitions = current_user.instructor_roles.map do |scope|
      authorization_definition_id = scope.split(':').first
      AuthorizationDefinition.find(authorization_definition_id)
    end

    @definitions.select! { |definition| definition.feature?('instructor_drafts', default: false) }
  end

  def instructor_draft_request_params
    authorization_request_form = AuthorizationRequestForm.find(params[:authorization_request][:form_uid])

    {
      authorization_request_class: authorization_request_form.authorization_request_class.to_s,
      form_uid: authorization_request_form.uid,
    }
  end

  def authorization_request_params
    params.require(:authorization_request)
  rescue ActionController::ParameterMissing
    ActionController::Parameters.new
  end

  def prepare_request
    @authorization_request = @instructor_draft_request.request.decorate
  end

  def model_to_track_for_impersonation
    @instructor_draft_request
  end

  def authorize_instructor
    authorize %i[instruction instructor_draft_request], :enabled?
  end
end
