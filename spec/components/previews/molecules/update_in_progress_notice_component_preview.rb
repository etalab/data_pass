# @label Bandeau « mise à jour en cours »
#
# Bandeau d’information pleine largeur signalant qu’une demande de mise à jour de l’habilitation est
# en cours d’instruction, avec un lien vers cette demande.
#
# **Où** : page d’une habilitation, via `Habilitation::UserAlertsComponent`, et page de
# récapitulatif d’une demande, via `Applicant::DemandeAlertsComponent`.
#
# **Quand** : `render?` exige que l’habilitation soit la dernière version (`latest?`) et que sa
# demande soit en cours de mise à jour (`reopening?`).
class Molecules::UpdateInProgressNoticeComponentPreview < ApplicationPreview
  # @label 1. Habilitation dont la mise à jour est en cours
  #
  # Le bandeau bleu « Une mise à jour de cette habilitation est en cours », avec le lien vers la
  # demande de mise à jour ; c’est le seul rendu possible du composant.
  #
  # **Où** : page d’une habilitation (`Habilitation::UserAlertsComponent`) et récapitulatif d’une
  # demande (`Applicant::DemandeAlertsComponent`) ; `render?` exige `latest?` et `reopening?`.
  def default
    authorization = Authorization.joins(:request).where(authorization_requests: { state: 'draft' }).first
    render Molecules::UpdateInProgressNoticeComponent.new(authorization:)
  end
end
