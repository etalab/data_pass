class AssignDefaultDataToAuthorizationRequest < ApplicationInteractor
  def call
    context.authorization_request.assign_attributes(
      default_data
    )
  end

  private

  def default_data
    context.authorization_request_form.initialize_with
  end
end
