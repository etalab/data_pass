class InstructorDraftRequestMailer < AbstractInstructionMailer
  def invite_applicant
    @instructor_draft_request = params[:instructor_draft_request]

    mail(
      to: @instructor_draft_request.applicant.email,
      bcc: instructors_or_reporters_to_notify.pluck(:email),
      subject: t('.subject', project_name: @instructor_draft_request.project_name)
    )
  end

  protected

  def model_for_instructors_or_reporters
    @instructor_draft_request
  end
end
