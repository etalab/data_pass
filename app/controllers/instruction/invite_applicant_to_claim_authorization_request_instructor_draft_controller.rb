class Instruction::InviteApplicantToClaimAuthorizationRequestInstructorDraftController < InstructionController
  before_action :find_authorization_request_instructor_draft
  before_action :authorize_instructor_draft

  def new; end

  def create
    organizer = InviteApplicantToClaimAuthorizationRequestInstructorDraft.call(
      authorization_request_instructor_draft: @authorization_request_instructor_draft,
      applicant_email: params[:applicant_email],
      organization_siret: params[:organization_siret]
    )

    if organizer.success?
      success_message(title: t('.success'))

      redirect_to instruction_authorization_request_instructor_drafts_path, status: :see_other
    else
      @error = t(".error.#{organizer.error}")

      render :new, status: :unprocessable_entity
    end
  end

  private

  def find_authorization_request_instructor_draft
    @authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.find(params[:authorization_request_instructor_draft_id])
  end

  def authorize_instructor_draft
    # authorize [:instruction, @authorization_request_instructor_draft]
  end
end
