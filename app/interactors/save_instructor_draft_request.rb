class SaveInstructorDraftRequest < ApplicationInteractor
  def call
    context.instructor_draft_request.data = Hash(context.authorization_request&.data)
    context.instructor_draft_request.save || context.fail!
  end
end
