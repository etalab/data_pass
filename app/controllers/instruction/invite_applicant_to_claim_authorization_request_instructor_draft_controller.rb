class Instruction::InviteApplicantToClaimAuthorizationRequestInstructorDraftController < InstructionController
  before_action :find_authorization_request_instructor_draft
  before_action :authorize_instructor_draft

  def new; end

  def create
    organizer = InviteApplicantToClaimAuthorizationRequestInstructorDraft.call(
      authorization_request_instructor_draft_params.merge(
        authorization_request_instructor_draft: @authorization_request_instructor_draft,
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
    success_message(title: t('.success'))

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.action(:refresh, '')
      end

      format.html do
        redirect_to instruction_authorization_request_instructor_drafts_path,
          status: :see_other
      end
    end
  end

  def find_authorization_request_instructor_draft
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.find(params[:authorization_request_instructor_draft_id])
  end

  def authorization_request_instructor_draft_params
    params.expect(authorization_request_instructor_draft: %i[applicant_email organization_siret])
  end

  def authorize_instructor_draft
    authorize [:instruction, @authorization_request_instructor_draft]
  end

  def model_to_track_for_impersonation
    @authorization_request_instructor_draft
  end
end
