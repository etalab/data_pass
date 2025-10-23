class Instruction::InstructorDraftRequests::InviteController < InstructionController
  before_action :find_instructor_draft_request
  before_action :authorize_instructor_draft

  def new; end

  def create
    organizer = InviteApplicantToClaimInstructorDraftRequest.call(
      instructor_draft_request_params.merge(
        instructor_draft_request: @instructor_draft_request,
      ),
    )

    if organizer.success?
      handle_create_success
    else
      @error = t(".error.message.#{organizer.error}")

      render :new, status: :unprocessable_entity
    end
  end

  private

  def handle_create_success
    success_message(title: t('instruction.instructor_draft_requests.invite.create.success'))

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.action(:refresh, '')
      end

      format.html do
        redirect_to instruction_instructor_draft_requests_path,
          status: :see_other
      end
    end
  end

  def find_instructor_draft_request
    @instructor_draft_request = InstructorDraftRequest.find(params[:instructor_draft_request_id])
  end

  def instructor_draft_request_params
    params.expect(instructor_draft_request: %i[applicant_email organization_siret comment])
  end

  def authorize_instructor_draft
    authorize [:instruction, @instructor_draft_request], :invite?
  end

  def model_to_track_for_impersonation
    @instructor_draft_request
  end
end
