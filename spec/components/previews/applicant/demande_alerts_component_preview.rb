# @label Alertes demande (demandeur)
class Applicant::DemandeAlertsComponentPreview < ApplicationPreview
  # @label 1. Résumé avant soumission
  def summary_before_submit
    authorization_request = AuthorizationRequest.where(state: 'draft').where(last_validated_at: nil).first!

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: authorization_request.applicant)
  end

  # @label 2. Mention en tant que contact
  def contact_mention
    contact_user = User.find_by!(email: 'user@yopmail.com')
    authorization_request = AuthorizationRequest
      .where(state: 'validated')
      .where("EXISTS (
        SELECT 1 FROM each(authorization_requests.data) AS kv
        WHERE kv.key LIKE '%_email' AND LOWER(kv.value) = ?
      )", contact_user.email)
      .first!

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: contact_user)
  end

  # @label 3a. Demande de modifications
  def changes_requested
    authorization_request = AuthorizationRequest.where(state: 'changes_requested').first!

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: authorization_request.applicant)
  end

  # @label 3b. Demande refusée
  def refused
    authorization_request = AuthorizationRequest.where(state: 'refused').first!

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: authorization_request.applicant)
  end

  # @label 4. Import V1 invalide
  def dirty_from_v1
    authorization_request = AuthorizationRequest.first!
    authorization_request.dirty_from_v1 = true

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: authorization_request.applicant)
  end

  # @label 5. Mise à jour de la demande en cours
  def update_in_progress
    authorization_request = AuthorizationRequest.where(state: 'draft').where.not(last_validated_at: nil).first!
    authorization = authorization_request.latest_authorization

    render Applicant::DemandeAlertsComponent.new(authorization_request:, authorization:, current_user: authorization_request.applicant)
  end
end
