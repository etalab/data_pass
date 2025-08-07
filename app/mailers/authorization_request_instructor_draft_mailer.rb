class AuthorizationRequestInstructorDraftMailer < ApplicationMailer
  def invite_applicant
    @authorization_request_instructor_draft = params[:authorization_request_instructor_draft]

    mail(
      to: @authorization_request_instructor_draft.applicant.email,
      cc: @authorization_request_instructor_draft.instructor.email,
      subject: t('.subject', project_name: @authorization_request_instructor_draft.project_name)
    )
  end
end
