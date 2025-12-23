# @label Alertes utilisateur sur une habilitation
class Habilitation::UserAlertsComponentPreview < ApplicationPreview
  # @label 1. Mise à jour de la demande en cours
  def update_in_progress
    authorization_request = AuthorizationRequest.where(state: 'draft').where.not(last_validated_at: nil).first!
    authorization = authorization_request.latest_authorization

    render Habilitation::UserAlertsComponent.new(authorization:, current_user: authorization_request.applicant)
  end

  # @label 2. Bandeau accès disponible
  def access_callout
    authorization_request = AuthorizationRequest
      .where(type: 'AuthorizationRequest::APIEntreprise')
      .where.not(external_provider_id: nil)
      .find { |ar| ar if ar.access_link.present? && ar.validated? }

    render Habilitation::UserAlertsComponent.new(authorization: authorization_request.latest_authorization, current_user: authorization_request.applicant)
  end
end
