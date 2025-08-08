class RegenerateAuthorizationRequestInstructorDraftPublicId < ApplicationInteractor
  def call
    context.authorization_request_instructor_draft.update!(
      public_id: SecureRandom.uuid
    )
  end
end
