class RestoreAuthorizationRequestToAuthorization < ApplicationInteractor
  delegate :authorization_request, :authorization, to: :context, private: true

  def call
    return if authorization.nil?

    fill_authorization_request_with_authorization_data!

    authorization_request.save(validate: false)
  end

  private

  def fill_authorization_request_with_authorization_data!
    interactor = AssignParamsToAuthorizationRequest.call(
      authorization_request:,
      authorization_request_params:,
      skip_validation: true,
    )
    authorization_request.type = authorization.authorization_request_class

    return if interactor.success?

    context.fail!
  end

  def authorization_request_params
    ActionController::Parameters.new(authorization.data)
  end
end
