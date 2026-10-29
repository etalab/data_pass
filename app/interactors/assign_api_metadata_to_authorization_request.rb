class AssignAPIMetadataToAuthorizationRequest < ApplicationInteractor
  def call
    return unless context.api_metadata_provided

    authorization_request.assign_metadata(:api, context.api_metadata)

    return if authorization_request.save(context: context.save_context)

    fail_with_error(:authorization_request_invalid, errors: authorization_request.errors.full_messages)
  end

  private

  def authorization_request
    context.authorization_request
  end
end
