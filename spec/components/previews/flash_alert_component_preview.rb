# @label Message flash
#
# Alerte DSFR affichant un message de retour après une action : titre, description facultative et
# liste d’erreurs facultative.
#
# **Où** : partout dans le produit, via le partiel `shared/_alerts`, inclus dans les gabarits
# `container`, `wide_container`, `admin`, `instruction/authorization_request`,
# `authorization_with_tabs` et `authorization_request_with_tabs`, ainsi que dans quelques vues qui
# le rendent directement (nouvelle organisation, brouillon instructeur, espace développeurs). Rendu
# aussi en direct dans `admin/data_providers/create.turbo_stream`.
#
# **Quand** : une clé `flash` est posée par le contrôleur — `error`, `info`, `success` ou `warning`
# (`ApplicationController#success_message` et `#error_message`). Le partiel boucle sur les quatre
# clés et n’affiche que celles qui sont présentes.
#
# La variante réduite se déclenche par la clé `tiny` du flash : elle ne rend que le titre, en alerte
# `sm`, et ignore description et erreurs. Le bouton de fermeture est toujours présent dans cette
# variante, alors qu’ailleurs il se désactive via `close_button: false` (cas de
# `claim_instructor_draft_requests/denied`).
class FlashAlertComponentPreview < ApplicationPreview
  # @label 1. Succès
  #
  # Forme complète du retour positif : titre et description, dans l’alerte DSFR verte.
  #
  # **Où** : partout dans le produit, via le partiel `shared/_alerts`, dès qu’un contrôleur pose une
  # clé `flash` (`ApplicationController#success_message`).
  def success
    render FlashAlertComponent.new(
      type: :success,
      data: { 'title' => 'Succès', 'description' => 'Opération réussie' }
    )
  end

  # @label 2. Succès, variante réduite (titre seul)
  #
  # Variante déclenchée par la clé `tiny` du flash : alerte `sm` réduite au titre, description et
  # erreurs ignorées, bouton de fermeture toujours présent.
  #
  # **Où** : partout dans le produit, via le partiel `shared/_alerts`, dès qu’un contrôleur pose une
  # clé `flash` assortie de `tiny`.
  def success_tiny
    render FlashAlertComponent.new(
      type: :success,
      data: { 'title' => 'Sauvegardé', 'tiny' => true }
    )
  end

  # @label 3. Erreur avec liste de messages
  #
  # Seul scénario qui exerce la clé `errors` : les messages détaillés s’empilent en liste sous la
  # description, après une soumission refusée.
  #
  # **Où** : partout dans le produit, via le partiel `shared/_alerts`, dès qu’un contrôleur pose une
  # clé `flash` (`ApplicationController#error_message`).
  def error_with_messages
    render FlashAlertComponent.new(
      type: :error,
      data: {
        'title' => 'Erreur',
        'description' => 'Des erreurs sont survenues',
        'errors' => ['Champ requis', 'Format invalide']
      }
    )
  end

  # @label 4. Avertissement
  #
  # Déclinaison `warning` : l’action a abouti mais appelle une vérification. Sert surtout à comparer
  # la couleur et l’icône aux trois autres types.
  #
  # **Où** : partout dans le produit, via le partiel `shared/_alerts`, dès qu’un contrôleur pose une
  # clé `flash`.
  def warning
    render FlashAlertComponent.new(
      type: :warning,
      data: { 'title' => 'Attention', 'description' => 'Vérifiez les informations' }
    )
  end

  # @label 5. Information
  #
  # Déclinaison `info`, la plus neutre : simple note de contexte, sans notion de réussite ni
  # d’échec.
  #
  # **Où** : partout dans le produit, via le partiel `shared/_alerts`, dès qu’un contrôleur pose une
  # clé `flash`.
  def info
    render FlashAlertComponent.new(
      type: :info,
      data: { 'title' => 'Information', 'description' => 'Note informative' }
    )
  end
end
