class MarkInstructorDraftAsClaimed < ApplicationInteractor
  def call
    instructor_draft = context.authorization_request_instructor_draft

    return unless instructor_draft

    return if instructor_draft.update(claimed: true)

    context.fail!(message: "Failed to mark draft as claimed: #{instructor_draft.errors.full_messages.join(', ')}")
  end
end
