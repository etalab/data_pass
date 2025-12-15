class FindAuthorizationRequest < ApplicationInteractor
  def call
    context.authorization_request = AuthorizationRequest.find_by(id: context.authorization_request_id)

    return if context.authorization_request.present?

    context.fail!(error: :authorization_request_not_found)
  end
end
