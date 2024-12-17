class CopyDocumentsFromInstructorDraft < ApplicationInteractor
  def call
    instructor_draft = context.instructor_draft_request
    authorization_request = context.authorization_request

    return unless instructor_draft && authorization_request

    instructor_draft.documents.each do |instructor_draft_document|
      instructor_draft_document.files.each do |file|
        authorization_request.public_send(instructor_draft_document.identifier).attach(file.blob)
      end
    end
  end
end
