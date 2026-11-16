class ValidateAPIDataObject < ApplicationInteractor
  def call
    return if context.authorization_request_params.is_a?(ActionController::Parameters)

    fail_with_error(:invalid_data)
  end
end
