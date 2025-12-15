class UpdateInstructorDraftRequestWithUserAndOrganization < ApplicationInteractor
  def call
    context.instructor_draft_request.update!(
      applicant: context.user,
      organization: context.organization
    )
  end
end
