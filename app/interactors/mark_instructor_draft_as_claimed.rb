class MarkInstructorDraftAsClaimed < ApplicationInteractor
  def call
    instructor_draft = context.instructor_draft_request

    return unless instructor_draft

    return if instructor_draft.update(claimed: true)

    context.fail!(error: :could_not_mark_draft_as_claimed)
  end
end
