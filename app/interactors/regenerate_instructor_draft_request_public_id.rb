class RegenerateInstructorDraftRequestPublicId < ApplicationInteractor
  def call
    context.instructor_draft_request.update!(
      public_id: SecureRandom.uuid
    )
  end
end
