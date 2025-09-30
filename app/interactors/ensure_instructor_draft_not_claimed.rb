class EnsureInstructorDraftNotClaimed < ApplicationInteractor
  def call
    instructor_draft = context.authorization_request_instructor_draft

    return unless instructor_draft

    return unless instructor_draft.claimed?

    context.fail!(error: :draft_already_claimed)
  end
end
