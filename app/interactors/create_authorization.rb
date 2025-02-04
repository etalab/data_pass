class CreateAuthorization < ApplicationInteractor
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
    authorization_request.class.documents.each do |document_identifier|
      storage_file_model = authorization_request.public_send(document_identifier)
      next if storage_file_model.blank?

      document = context.authorization.documents.create!(
        identifier: document_identifier,
      )
      document.file.attach(storage_file_model.blob)
    end
  end

  def authorization_request
    context.authorization_request
  end

  def authorization_params
    {
      data: authorization_request.data,
      applicant: authorization_request.applicant,
      form_uid: authorization_request.form_uid,
    }
  end
end
