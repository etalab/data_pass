class APIInfinoeSandboxBridge < ApplicationBridge
  def perform
    return if authorization_request.production_authorization_request.present?

    create_production_authorization_request
  end

  private

  def create_production_authorization_request
    production_authorization_request = AuthorizationRequest::APIInfinoeProduction.new(
      organization: authorization_request.organization,
      applicant: authorization_request.applicant,
      form_uid: 'api-infinoe-production',
    )

    production_authorization_request.sandbox_authorization_request = authorization_request

    production_authorization_request.save!
  end
end
