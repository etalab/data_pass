class EnsureInstructorDraftCanBeClaimed < ApplicationInteractor
  def call
    return unless context.instructor_draft_request && context.user

    violation = rules.creation_violation

    context.fail!(error: violation) if violation
  end

  private

  def rules
    AuthorizationRequestCreationRules.for_instructor_draft(
      context.instructor_draft_request,
      applicant: context.user
    )
  end
end
