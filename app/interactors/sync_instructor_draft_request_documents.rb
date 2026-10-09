class SyncInstructorDraftRequestDocuments < ApplicationInteractor
  include AuthorizationRequestPermittedKeys

  def call
    return unless context.instructor_draft_request&.persisted?

    submitted_documents.each do |identifier, attachables|
      sync_document(identifier, Array(attachables))
    end
  end

  private

  def submitted_documents
    context.authorization_request_params.permit(permitted_documents).to_h
  end

  def sync_document(identifier, attachables)
    document = context.instructor_draft_request.documents.find_or_initialize_by(identifier:)
    return if document.new_record? && attachables.compact_blank.empty?

    document.files = attachables
    document.save || context.fail!
  end
end
