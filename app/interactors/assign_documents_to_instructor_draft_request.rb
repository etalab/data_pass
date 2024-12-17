class AssignDocumentsToInstructorDraftRequest < ApplicationInteractor
  include DocumentsAffector

  def call
    return unless context.instructor_draft_request

    affect_documents!
  end

  private

  def create_document(document_identifier)
    context.instructor_draft_request.documents.create!(
      identifier: document_identifier.name
    )
  end
end
