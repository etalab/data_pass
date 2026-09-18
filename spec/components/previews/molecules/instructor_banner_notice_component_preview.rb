# @label Bandeau de réponse de l’instruction
#
# Bandeau pleine largeur reprenant la décision rendue sur une demande — demande de modifications
# (orange) ou refus (rouge) — suivi du motif écrit par l’instructeur.
#
# **Où** : page de récapitulatif d’une demande, à l’intérieur de
# `Applicant::DemandeAlertsComponent`.
#
# **Quand** : `render?` ne l’affiche que si la demande est dans l’état `changes_requested` ou
# `refused`.
#
# Le texte change encore selon `reopening?` : une demande de mise à jour reçoit les libellés «
# reopening_changes_requested » / « reopening_refused », pas ceux d’une première demande. Un refus
# prononcé sur une mise à jour s’affiche donc en rouge avec un libellé différent de celui des
# previews ci-dessous.
class Molecules::InstructorBannerNoticeComponentPreview < ApplicationPreview
  # @label 1. Demande de modifications (orange)
  #
  # Le bandeau orange d’une demande dans l’état `changes_requested` : titre « Votre demande
  # d’habilitation nécessite des modifications avant d’être validée », puis le motif écrit par
  # l’instructeur.
  #
  # **Où** : page de récapitulatif d’une demande, dans `Applicant::DemandeAlertsComponent` ;
  # `render?` exige l’état `changes_requested` ou `refused`.
  def changes_requested
    authorization_request = AuthorizationRequest.changes_requested.first
    render Molecules::InstructorBannerNoticeComponent.new(authorization_request:)
  end

  # @label 2. Demande refusée (rouge)
  #
  # Le même bandeau en rouge pour l’état `refused` : « Votre demande d’habilitation a été refusée »,
  # suivi du motif.
  #
  # Cas non couvert par les previews : sur une demande de mise à jour (`reopening?`), les libellés
  # deviennent « reopening_changes_requested » / « reopening_refused ».
  #
  # **Où** : page de récapitulatif d’une demande, dans `Applicant::DemandeAlertsComponent` ;
  # `render?` exige l’état `changes_requested` ou `refused`.
  def refused
    authorization_request = AuthorizationRequest.refused.first
    render Molecules::InstructorBannerNoticeComponent.new(authorization_request:)
  end
end
