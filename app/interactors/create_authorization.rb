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

      create_document_snapshots(storage_file_model, document_identifier)
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

  def create_document_snapshots(storage_file_model, document_identifier)
    if storage_file_model.respond_to?(:any?)
      create_multiple_documents(storage_file_model, document_identifier)
    else
      create_single_document(storage_file_model, document_identifier)
    end
  end

  def create_multiple_documents(storage_files, document_identifier)
    storage_files.each do |file|
      create_and_attach_document(file, document_identifier)
    end
  end

  def create_single_document(storage_file, document_identifier)
    create_and_attach_document(storage_file, document_identifier)
  end

  def create_and_attach_document(file, document_identifier)
    document = context.authorization.documents.create!(
      identifier: document_identifier
    )
    document.file.attach(file.blob)
  end
end
