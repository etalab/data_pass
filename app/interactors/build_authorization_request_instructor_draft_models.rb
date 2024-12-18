class BuildAuthorizationRequestInstructorDraftModels < ApplicationInteractor
  def call
    build_authorization_request_instructor_draft_model
    build_authorization_request_model
  end

  private

  def build_authorization_request_instructor_draft_model
    context.authorization_request_instructor_draft = AuthorizationRequestInstructorDraft.new(
      context.authorization_request_instructor_draft_params.merge(
        instructor: context.instructor,
      )
    )
  end

  def build_authorization_request_model
    context.authorization_request = context.authorization_request_instructor_draft.authorization_request_class.constantize.new(
      applicant: context.instructor,
      organization: context.instructor.current_organization,
    )
    context.authorization_request.form_uid = context.authorization_request.definition.default_form.id
  end
end
