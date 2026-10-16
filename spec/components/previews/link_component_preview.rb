# @label Lien
#
# Lien DSFR (`fr-link`) qui pose par défaut `rel="noopener"`. Une classe passée en option s’ajoute à
# `fr-link`, un `rel` passé en option remplace `noopener`, les autres options s’ajoutent telles
# quelles.
#
# **Où** : historique d’une demande, sous un événement de validation (`approve`) ou de création
# automatique d’habilitation (`auto_generate`), rendu par `HistoricalAuthorizationRequestEventComponent`.
# Deux pages l’utilisent : `authorization_request_events/index` côté demandeur et
# `instruction/authorization_request_events/index` côté instruction.
#
# **Quand** : l’événement est une validation (`approve`) ou une création automatique d’habilitation
# (`auto_generate`), condition portée par `HistoricalAuthorizationRequestEventComponent#external_link?`.
# Le lien mène à l’habilitation produite par cet événement.
class LinkComponentPreview < ApplicationPreview
  # @label Lien vers l’habilitation d’un événement de validation
  #
  # L’usage réel : le texte de l’événement `approve`, avec le nom du type d’habilitation et son
  # numéro en gras, pointe vers la page de l’habilitation validée.
  #
  # **Où** : historique d’une demande, côté demandeur comme côté instruction.
  def default
    render LinkComponent.new(
      text: approve_event_link_text,
      path: authorization_path(authorization)
    )
  end

  private

  def authorization
    AuthorizationRequestEvent.where(name: 'approve').first!.authorization
  end

  def approve_event_link_text
    I18n.t(
      'instruction.authorization_request_events.authorization_request_event.approve.view_authorization',
      definition_name: authorization.definition.name,
      formatted_id: authorization.formatted_id
    ).html_safe
  end
end
