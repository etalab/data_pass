class UpdateAuthorizationRequestInstructorDraftWithUserAndOrganization < ApplicationInteractor
  def call
    context.authorization_request_instructor_draft.update!(
      applicant: context.user,
      organization: context.organization
    )
  end
end
