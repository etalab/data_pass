# @label Alertes demande (instructeur)
class Instructor::DemandeAlertsComponentPreview < ApplicationPreview
  # @label Mise à jour en cours
  def reopening_in_progress
    authorization_request = AuthorizationRequest.where(state: 'draft').where.not(last_validated_at: nil).first!

    render Instructor::DemandeAlertsComponent.new(authorization_request:)
  end
end
