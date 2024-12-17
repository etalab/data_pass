class SendInvitationEmailInstructorDraftRequest < ApplicationInteractor
  def call
    InstructorDraftRequestMailer.with(
      instructor_draft_request: context.instructor_draft_request
    ).invite_applicant.deliver_later
  end
end
