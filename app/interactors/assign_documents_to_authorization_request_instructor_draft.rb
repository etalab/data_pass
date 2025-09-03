class AssignDocumentsToAuthorizationRequestInstructorDraft < ApplicationInteractor
  include DocumentsAffector

  def call
    return unless context.authorization_request_instructor_draft

    affect_documents!
  end

  private

  def create_document(document_identifier)
    context.authorization_request_instructor_draft.documents.create!(
      identifier: document_identifier.name
    )
  end
end
