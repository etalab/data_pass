class RestoreAuthorizationRequestToLatestAuthorization < ApplicationInteractor
  delegate :authorization_request, to: :context, private: true
  delegate :latest_authorization, to: :authorization_request, private: true

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
    authorization_request.type = latest_authorization.authorization_request_class

    return if interactor.success?

    context.fail!
  end

  def authorization_request_params
    ActionController::Parameters.new(latest_authorization.data)
  end
end
