class AuthorizationRequestInstructorDraftMailerPreview < ActionMailer::Preview
  def invite_applicant
    AuthorizationRequestInstructorDraftMailer.with(
      authorization_request_instructor_draft: authorization_request_instructor_draft
    ).invite_applicant
  end

  private

  def authorization_request_instructor_draft
    AuthorizationRequestInstructorDraft.joins(:applicant, :organization).first
  end
end
