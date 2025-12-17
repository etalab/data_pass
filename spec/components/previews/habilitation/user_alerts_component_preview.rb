# @label Alertes utilisateur sur une habilitation
class Habilitation::UserAlertsComponentPreview < ApplicationPreview
  # @label 1. Mention en tant que contact
  def contact_mention
    contact_user = User.find_by!(email: 'user@yopmail.com')
    authorization_request = AuthorizationRequest
      .where(state: 'validated')
      .where("EXISTS (
      select 1
      from each(authorization_requests.data) as kv
      where kv.key like '%_email' and lower(kv.value) = ?
    )", contact_user.email)
      .first!

    render Habilitation::UserAlertsComponent.new(authorization: authorization_request.latest_authorization, current_user: contact_user)
  end

  # @label 2. Mise à jour de la demande en cours
  def update_in_progress
    authorization_request = AuthorizationRequest.where(state: 'draft').where.not(last_validated_at: nil).first!
    authorization = authorization_request.latest_authorization

    render Habilitation::UserAlertsComponent.new(authorization:, current_user: authorization_request.applicant)
  end

  # @label 3. Bandeau accès disponible
  def access_callout
    authorization_request = AuthorizationRequest
      .where(type: 'AuthorizationRequest::APIEntreprise')
      .where.not(external_provider_id: nil)
      .find { |ar| ar if ar.access_link.present? && ar.validated? }

    render Habilitation::UserAlertsComponent.new(authorization: authorization_request.latest_authorization, current_user: authorization_request.applicant)
  end
end
