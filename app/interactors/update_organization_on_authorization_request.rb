class UpdateOrganizationOnAuthorizationRequest < ApplicationInteractor
  def call
    context.authorization_request.organization = context.new_organization
    context.authorization_request.applicant = context.new_applicant

    return if context.authorization_request.save

    context.fail!(error: :invalid_new_organization)
  end
end
