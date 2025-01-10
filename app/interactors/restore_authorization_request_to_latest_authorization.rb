class RestoreAuthorizationRequestToLatestAuthorization < ApplicationInteractor
  def call
    return if latest_authorization.nil?

    fill_authorization_request_with_latest_authorization_data!

    authorization_request.save
  end

  private

  def fill_authorization_request_with_latest_authorization_data!
    interactor = AssignParamsToAuthorizationRequest.call(
      authorization_request:,
      authorization_request_params:,
      save_context: :submit,
    )

    return if interactor.success?

    context.fail!
  end

  def authorization_request_params
    ActionController::Parameters.new(latest_authorization.data)
  end

  def authorization_request
    context.authorization_request
  end

  def latest_authorization
    authorization_request.latest_authorization
  end
end
