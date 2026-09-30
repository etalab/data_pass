# @label Alertes utilisateur sur une habilitation
#
# Bandeaux affichés en tête d’une habilitation : le rappel qu’une mise à jour est en cours
# d’instruction, et l’encart d’accès au service habilité, avec son bouton vers le lien d’accès
# ouvert dans une nouvelle fenêtre.
#
# **Où** : page d’une habilitation (`app/views/authorizations/show.html.erb`), au-dessus du bloc «
# organisation et demandeur ».
#
# **Pour qui** : l’encart d’accès n’est montré qu’au demandeur lui-même (`current_user ==
# authorization_request.applicant`), et seulement si la demande est validée et porte un
# `access_link`. Le bandeau de mise à jour, lui, dépend de l’état (`authorization.latest?` et
# `authorization_request.reopening?`).
class Habilitation::UserAlertsComponentPreview < ApplicationPreview
  # @label 1. Mise à jour de la demande en cours
  #
  # Habilitation à jour dont la demande a été rouverte : seul le bandeau bleu « Une mise à jour de
  # cette habilitation est en cours » s’affiche, sans l’encart d’accès.
  #
  # **Où** : page d’une habilitation (`authorizations/show`), au-dessus du bloc « organisation et
  # demandeur » ; conditions `authorization.latest?` et `authorization_request.reopening?`.
  def update_in_progress
    authorization_request = AuthorizationRequest.where(state: 'draft').where.not(last_validated_at: nil).first!
    authorization = authorization_request.latest_authorization

    render Habilitation::UserAlertsComponent.new(authorization:, current_user: authorization_request.applicant)
  end

  # @label 2. Bandeau accès disponible
  #
  # Habilitation API Entreprise validée et pourvue d’un `access_link` : seul l’encart d’accès au
  # service s’affiche, avec son bouton ouvrant le lien dans une nouvelle fenêtre.
  #
  # **Où** : page d’une habilitation (`authorizations/show`) ; l’encart n’est montré qu’au demandeur
  # lui-même, sur une demande validée portant un `access_link`.
  def access_callout
    authorization_request = AuthorizationRequest
      .where(type: 'AuthorizationRequest::APIEntreprise')
      .where.not(external_provider_id: nil)
      .find { |ar| ar if ar.access_link.present? && ar.validated? }

    render Habilitation::UserAlertsComponent.new(authorization: authorization_request.latest_authorization, current_user: authorization_request.applicant)
  end
end
