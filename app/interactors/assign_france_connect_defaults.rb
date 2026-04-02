class AssignFranceConnectDefaults < ApplicationInteractor
  def call
    return unless should_assign_defaults?

    FranceConnectDefaultData.assign_to(authorization_request)
  end

  private

  delegate :authorization_request, to: :context, private: true

  def should_assign_defaults?
    authorization_request.is_a?(AuthorizationRequest::APIParticulier) &&
      authorization_request.france_connect_certified_form? &&
      authorization_request.france_connect_modality? &&
      authorization_request.france_connect_authorization_id.blank?
  end
end
