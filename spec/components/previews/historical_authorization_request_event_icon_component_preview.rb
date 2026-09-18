# @label Icône d’événement de demande d’autorisation
#
# Pictogramme coloré qui identifie la nature d’un événement dans l’historique d’une demande :
# validation en vert, demande de modifications en orange, refus et révocation en rouge, modification
# administrative en bleu.
#
# **Où** : historique d’une demande, en tête de chaque ligne de la chronologie, rendu par
# `HistoricalAuthorizationRequestEventComponent`. Deux pages l’utilisent :
# `authorization_request_events/index` côté demandeur et
# `instruction/authorization_request_events/index` côté instruction.
#
# Le composant redéfinit `icon_class` pour tomber sur une icône générique (`error-warning-line`,
# bleue) quand le nom d’événement n’est pas dans sa table, là où `IconComponent` lèverait une
# erreur. Seuls les cinq noms proposés ci-dessous y figurent ; tous les autres événements de
# `AuthorizationRequestEvent::NAMES` prennent l’icône générique.
class HistoricalAuthorizationRequestEventIconComponentPreview < ApplicationPreview
  # @param name select { choices: ['approve', 'request_changes', 'refuse', 'revoke', 'admin_change'] } "Type d’événement"
  #
  # Scénario unique, piloté par le sélecteur « Type d’événement » : chaque nom change l’icône et sa
  # couleur — validation en vert, demande de modifications en orange, refus et révocation en rouge,
  # modification administrative en bleu. Les cinq noms proposés sont les seuls présents dans la
  # table du composant ; tout autre événement de `AuthorizationRequestEvent::NAMES` retomberait sur
  # l’icône générique bleue `error-warning-line`.
  #
  # **Où** : historique d’une demande, en tête de chaque ligne de la chronologie, côté demandeur
  # (`authorization_request_events/index`) comme côté instruction.
  def default(name: 'approve')
    render HistoricalAuthorizationRequestEventIconComponent.new(name:)
  end
end
