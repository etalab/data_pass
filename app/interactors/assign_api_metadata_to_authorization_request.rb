class AssignAPIMetadataToAuthorizationRequest < ApplicationInteractor
  def call
    return if metadata_left_unchanged?

    authorization_request.assign_metadata(:api, context.api_metadata)

    return if authorization_request.save(context: context.save_context)

    fail_with_error(:authorization_request_invalid, errors: authorization_request.errors.full_messages)
  end

  private

  def metadata_left_unchanged?
    context.api_metadata.nil?
  end

  def authorization_request
    context.authorization_request
  end
end
