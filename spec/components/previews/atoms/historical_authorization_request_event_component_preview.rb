# @label Événement de l’historique d’une demande
#
# Une ligne de la chronologie d’une demande : l’icône de l’événement, la phrase qui le résume, la
# date, et selon l’événement un bouton qui déplie le détail (motif, message, modifications) ou un
# lien vers l’habilitation délivrée.
#
# **Où** : historique d’une demande, rendu en collection dans
# `authorization_request_events/index` côté demandeur et
# `instruction/authorization_request_events/index` côté instruction.
#
# **Pour qui** : demandeur et instructeurs voient la même ligne ; seul un admin, côté instruction,
# voit en plus le motif privé d’une modification administrative
# (`show_private_reason: current_user&.admin?`).
#
# L’aperçu entoure l’événement d’un `ul` : le composant rend un `li`, qui n’a de sens que dans une
# liste.
#
# Les événements viennent des demandes de référence de `dem-commune@yopmail.com`. Aucun événement
# `admin_change` n’est présent dans les seeds : la famille « détails d’une modification
# administrative » n’a donc pas de scénario. La famille « voir les modifications » non plus : les
# soumissions de `dem-commune` ne portent aucune modification à déplier.
#
# Piège : le layout des aperçus (`layouts/component_preview`) ne charge pas l’importmap, donc les
# contrôleurs Stimulus ne tournent pas dans Lookbook. Les boutons « voir le message » s’affichent
# mais ne déplient rien ici ; le contenu caché est visible dans l’onglet HTML.
class Atoms::HistoricalAuthorizationRequestEventComponentPreview < ApplicationPreview
  # @label 1. Événement simple
  #
  # Réouverture d’une habilitation par le demandeur : une phrase et une date, sans détail à déplier
  # ni lien.
  #
  # **Où** : historique d’une demande, côté demandeur comme côté instruction.
  def simple_event
    render_in_list(event_named('reopen'))
  end

  # @label 2. Refus avec motif dépliable
  #
  # Refus de la demande : le bouton « voir le message » déplie le motif saisi par l’instructeur,
  # « masquer le message » le replie. Même mécanisme pour une demande de modifications (icône
  # crayon orange) ou une révocation (même icône rouge).
  #
  # **Où** : historique d’une demande, côté demandeur comme côté instruction.
  def refusal_with_reason
    render_in_list(event_named('refuse'))
  end

  # @label 3. Message du demandeur
  #
  # Message envoyé par le demandeur depuis la messagerie : le bouton déplie le contenu du message.
  # Même affichage pour un message de l’instructeur.
  #
  # **Où** : historique d’une demande, côté demandeur comme côté instruction.
  def applicant_message
    render_in_list(event_named('applicant_message'))
  end

  # @label 4. Validation avec lien vers l’habilitation
  #
  # Validation de la demande : un lien mène à l’habilitation délivrée, identifiée par son type et
  # son numéro.
  #
  # **Où** : historique d’une demande, côté demandeur comme côté instruction.
  def approval_with_link
    render_in_list(event_named('approve'))
  end

  private

  def event_named(name)
    AuthorizationRequestEvent
      .joins(authorization_request: :applicant)
      .where(name:, users: { email: 'dem-commune@yopmail.com' })
      .order(:created_at)
      .first!
  end

  def render_in_list(event)
    render_with_template(
      template: 'atoms/historical_authorization_request_event_component_preview/in_list',
      locals: { event: }
    )
  end
end
