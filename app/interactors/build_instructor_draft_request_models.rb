class BuildInstructorDraftRequestModels < ApplicationInteractor
  def call
    build_instructor_draft_request_model
    build_authorization_request_model
  end

  private

  def build_instructor_draft_request_model
    context.instructor_draft_request = InstructorDraftRequest.new(
      context.instructor_draft_request_params.merge(
        instructor: context.instructor,
      )
    )
    ensure_form_uid
  end

  def ensure_form_uid
    return if context.instructor_draft_request.form_uid.present?

    context.instructor_draft_request.form_uid = context.instructor_draft_request.definition.default_form.id
  end

  def build_authorization_request_model
    context.authorization_request = authorization_request_class.new(
      applicant: instructor,
      organization: instructor.current_organization,
    )
    context.authorization_request.form_uid = form_uid
  end

  def form_uid
    context.instructor_draft_request.form_uid ||
      context.authorization_request.definition.default_form.id
  end

  def authorization_request_class
    context.instructor_draft_request.authorization_request_class.constantize
  end

  def instructor
    context.instructor
  end
end
