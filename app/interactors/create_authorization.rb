class CreateAuthorization < ApplicationInteractor
  include DocumentsAffector

  def call
    snapshot_authorization!
    snapshot_documents!
  end

  private

  def snapshot_authorization!
    context.authorization = authorization_request.authorizations.create!(
      authorization_params
    )
  end

  def snapshot_documents!
    affect_documents!
  end

  def create_document(document_identifier)
    context.authorization.documents.create!(
      identifier: document_identifier.name,
    )
  end

  def authorization_params
    {
      data: authorization_request.data,
      applicant: authorization_request.applicant,
    }
  end
end
