class ValidateAPIDocumentValues < ApplicationInteractor
  include AuthorizationRequestPermittedKeys

  def call
    return if invalid_keys.empty?

    fail_with_error(:invalid_document_values, errors: invalid_keys, format: :data_keys)
  end

  private

  def invalid_keys
    @invalid_keys ||= document_names.select { |name| contains_non_file?(name) }
  end

  def document_names
    authorization_request_class.documents.map { |document| document.name.to_s }
  end

  def contains_non_file?(name)
    Array(context.authorization_request_params[name])
      .reject { |value| uploaded_file?(value) }
      .compact_blank
      .any?
  end

  def uploaded_file?(value)
    value.respond_to?(:original_filename)
  end
end
