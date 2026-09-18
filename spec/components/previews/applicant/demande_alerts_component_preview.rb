# @label Alertes demande (demandeur)
#
# Pile de bandeaux et d’alertes affichée en tête du récapitulatif d’une demande : rappel de vérifier
# les informations avant de soumettre, réponse de l’instruction (modifications demandées ou refus),
# avertissement sur une demande importée de l’ancienne version, mise à jour en cours, et
# consultation d’une version périmée de l’habilitation.
#
# **Où** : page de récapitulatif d’une demande (`authorization_request_forms/summary`), juste
# au-dessus du bloc « organisation et demandeur ».
#
# **Pour qui** : le demandeur — la vue saute entièrement le composant sur les pages publiques
# (`displayed_on_a_public_page?`), et le rappel avant soumission n’apparaît que si `current_user`
# est bien `authorization_request.applicant`.
#
# Les cas se cumulent : `call` empile tous les bandeaux applicables dans l’ordre du composant, ce
# n’est pas un choix exclusif entre eux.
class Applicant::DemandeAlertsComponentPreview < ApplicationPreview
  # @label 1. Résumé avant soumission
  #
  # Brouillon jamais validé, consulté par son demandeur : seul le rappel « Vérifiez le récapitulatif
  # de votre demande avant de la soumettre » s’affiche.
  #
  # **Où** : récapitulatif d’une demande (`authorization_request_forms/summary`), au-dessus du bloc
  # « organisation et demandeur », et jamais sur une page publique.
  def summary_before_submit
    authorization_request = AuthorizationRequest.where(state: 'draft').where(last_validated_at: nil).first!

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: authorization_request.applicant)
  end

  # @label 2. Demande de modifications
  #
  # Demande en `changes_requested` : le bandeau orange de l’instruction s’affiche seul, le rappel
  # avant soumission disparaissant dès que la demande n’est plus un brouillon.
  #
  # **Où** : récapitulatif d’une demande (`authorization_request_forms/summary`), au-dessus du bloc
  # « organisation et demandeur », et jamais sur une page publique.
  def changes_requested
    authorization_request = AuthorizationRequest.where(state: 'changes_requested').first!

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: authorization_request.applicant)
  end

  # @label 3. Demande refusée
  #
  # Demande en `refused` : même logique que le scénario 2, avec le bandeau rouge de refus seul.
  #
  # **Où** : récapitulatif d’une demande (`authorization_request_forms/summary`), au-dessus du bloc
  # « organisation et demandeur », et jamais sur une page publique.
  def refused
    authorization_request = AuthorizationRequest.where(state: 'refused').first!

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: authorization_request.applicant)
  end

  # @label 4. Import V1 invalide
  #
  # Le premier cas où deux blocs se cumulent : le rappel avant soumission (la demande est un
  # brouillon) puis l’alerte « Cette demande ou cette habilitation comporte des erreurs ».
  #
  # **Où** : récapitulatif d’une demande (`authorization_request_forms/summary`), au-dessus du bloc
  # « organisation et demandeur », et jamais sur une page publique.
  def dirty_from_v1
    authorization_request = AuthorizationRequest.where(dirty_from_v1: true).first!

    render Applicant::DemandeAlertsComponent.new(authorization_request:, current_user: authorization_request.applicant)
  end

  # @label 5. Mise à jour de la demande en cours
  #
  # Autre cumul : le rappel avant soumission et le bandeau « Une mise à jour de cette habilitation
  # est en cours ». C’est le seul scénario où l’argument `authorization` est passé au composant.
  #
  # **Où** : récapitulatif d’une demande (`authorization_request_forms/summary`), au-dessus du bloc
  # « organisation et demandeur », et jamais sur une page publique.
  def update_in_progress
    authorization_request = AuthorizationRequest.where(state: 'draft').where.not(last_validated_at: nil).first!
    authorization = authorization_request.latest_authorization

    render Applicant::DemandeAlertsComponent.new(authorization_request:, authorization:, current_user: authorization_request.applicant)
  end
end
