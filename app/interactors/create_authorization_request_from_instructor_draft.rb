class CreateAuthorizationRequestFromInstructorDraft < ApplicationInteractor
  def call
    instructor_draft = context.instructor_draft_request
    user = context.user

    return unless instructor_draft && user

    authorization_request = build_authorization_request(instructor_draft, user)

    if authorization_request.save
      context.authorization_request = authorization_request
    else
      context.fail!(:invalid_authorization_request)
    end
  end

  private

  def build_authorization_request(instructor_draft, user)
    authorization_request_class = instructor_draft.authorization_request_class.constantize

    authorization_request_class.new(
      applicant: user,
      organization: instructor_draft.organization,
      data: instructor_draft.data,
      form_uid: instructor_draft.form_uid,
      state: 'draft'
    )
  end
end
