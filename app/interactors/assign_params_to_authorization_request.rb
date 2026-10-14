class AssignParamsToAuthorizationRequest < ApplicationInteractor
  include AuthorizationRequestPermittedKeys

  def call
    context.authorization_request.assign_attributes(
      valid_authorization_request_params
    )

    return if context.skip_validation || context.authorization_request.valid?(context.save_context)

    fail_with_error(
      :authorization_request_invalid,
      errors: context.authorization_request.errors.full_messages
    )
  end

  private

  def valid_authorization_request_params
    context.authorization_request_params.permit(
      extract_permitted_attributes.push(
        %i[
          terms_of_service_accepted
          data_protection_officer_informed
        ]
      )
    )
  end
end
