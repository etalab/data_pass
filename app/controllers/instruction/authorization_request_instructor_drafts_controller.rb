class Instruction::AuthorizationRequestInstructorDraftsController < InstructionController
  before_action :authorize_instructor

  def index
    @authorization_request_instructor_drafts = policy_scope([:instruction, AuthorizationRequestInstructorDraft]).includes(:instructor, :applicant)
  end

  private

  def authorize_instructor
    authorize %i[instruction authorization_request_instructor_draft], :enable?
  end
end
