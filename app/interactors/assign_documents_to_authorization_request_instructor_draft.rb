class AssignDocumentsToAuthorizationRequestInstructorDraft < ApplicationInteractor
  def call
    return unless context.authorization_request_instructor_draft

    affect_documents!
  end

  private

  def affect_documents!
    authorization_request.class.documents.each do |document_identifier|
      storage_file_model = authorization_request.public_send(document_identifier.name)
      next if storage_file_model.blank?

      document = create_document(document_identifier)
      attach_files_to_document(document, storage_file_model)
    end
  end

  def create_document(document_identifier)
    context.authorization_request_instructor_draft.documents.create!(
      identifier: document_identifier.name
    )
  end

  def attach_files_to_document(document, storage_file_model)
    Array(storage_file_model).each do |file|
      document.files.attach(file.blob)
    end
  end

  def authorization_request
    context.authorization_request
  end
end
