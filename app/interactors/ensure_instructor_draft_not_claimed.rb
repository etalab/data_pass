class EnsureInstructorDraftNotClaimed < ApplicationInteractor
  def call
    instructor_draft = context.instructor_draft_request

    return unless instructor_draft

    return unless instructor_draft.claimed?

    context.fail!(error: :draft_already_claimed)
  end
end
