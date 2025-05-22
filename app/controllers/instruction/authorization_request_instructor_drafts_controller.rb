class Instruction::AuthorizationRequestInstructorDraftsController < InstructionController
  helper AuthorizationRequestsHelpers

  before_action :authorize_instructor

  def index
    @authorization_request_instructor_drafts = policy_scope([:instruction, AuthorizationRequestInstructorDraft]).includes(:instructor, :applicant)
  end

  def new
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.new(authorization_request_class: 'AuthorizationRequest::APIEntreprise')
    @authorization_request = @authorization_request_instructor_draft.request.decorate

    render 'new', layout: 'application'
  end

  def create
    organizer = CreateAuthorizationRequestInstructorDraft.call(
      authorization_request_params:,
      authorization_request_instructor_draft_params: {
        authorization_request_class: 'AuthorizationRequest::APIEntreprise',
      },
      instructor: current_user,
    )

    if organizer.success?
      success_message(title: 'Congrats!')

      redirect_to instruction_authorization_request_instructor_draft_path(organizer.authorization_request_instructor_draft)
    else
      error_message(title: 'Booouu!')

      @authorization_request_instructor_draft = organizer.authorization_request_instructor_draft
      @authorization_request = @authorization_request_instructor_draft.request

      render 'new'
    end
  end

  def show
    @authorization_request_instructor_draft = current_organization.authorization_request_instructor_drafts.find(params[:id])
    @authorization_request = @authorization_request_instructor_draft.request

    render 'new'
  end

  private

  def authorization_request_params
    params.require(authorization_request_class.model_name.singular)
  rescue ActionController::ParameterMissing
    ActionController::Parameters.new
  end

  def authorization_request_class
    AuthorizationRequest::APIEntreprise
  end

  def authorize_instructor
    authorize %i[instruction authorization_request_instructor_draft], :enable?
  end
end
