class AuthorizationRequestInstructorDraftMailer < AbstractInstructionMailer
  def invite_applicant
    @authorization_request_instructor_draft = params[:authorization_request_instructor_draft]

    mail(
      to: @authorization_request_instructor_draft.applicant.email,
      bcc: instructors_or_reporters_to_notify.pluck(:email),
      subject: t('.subject', project_name: @authorization_request_instructor_draft.project_name)
    )
  end

  protected

  def model_for_instructors_or_reporters
    @authorization_request_instructor_draft
  end
end
