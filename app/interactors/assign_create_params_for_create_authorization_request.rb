class AssignCreateParamsForCreateAuthorizationRequest < ApplicationInteractor
  def call
    context.authorization_request = context.authorization_request_form.authorization_request_class.new(
      applicant:,
      organization:,
      form_uid: context.authorization_request_form.uid
    )
  end

  private

  def applicant
    context.applicant || context.user
  end

  def organization
    context.organization || applicant.current_organization
  end
end
