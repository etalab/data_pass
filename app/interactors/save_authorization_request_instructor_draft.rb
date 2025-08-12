class SaveAuthorizationRequestInstructorDraft < ApplicationInteractor
  def call
    context.authorization_request_instructor_draft.data = context.authorization_request&.data || {}
    context.authorization_request_instructor_draft.save || context.fail!
  end
end
