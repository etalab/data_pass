class SendInvitationEmailAuthorizationRequestInstructorDraft < ApplicationInteractor
  def call
    AuthorizationRequestInstructorDraftMailer.with(
      authorization_request_instructor_draft: context.authorization_request_instructor_draft
    ).invite_applicant.deliver_later
  end
end
