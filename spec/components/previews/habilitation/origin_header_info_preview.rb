# @label Origine de l’habilitation (sous-en-tête)
#
# Phrase affichée en bas du bandeau d’en-tête d’une habilitation, sous les badges, rappelant par
# quelle demande et quel formulaire l’habilitation a été délivrée.
#
# **Où** : page d’une habilitation, dans `AuthorizationHeaderComponent`.
#
# **Pour qui** : uniquement les personnes ayant accès à l’espace instruction — le bloc est
# conditionné par `policy([:instruction, request]).show?`, donc le demandeur ne le voit jamais.
#
# Le composant fixe sa couleur de texte à `fr-text-inverted--blue-france` (blanc), alors que
# l’en-tête passe en gris pour les états révoqué et obsolète : voir le scénario « 4. Obsolète », où
# le texte devient illisible.
class Habilitation::OriginHeaderInfoPreview < ApplicationPreview
  ACTIVE_HEADER_BACKGROUND = 'fr-background-action-high--blue-france'.freeze
  OBSOLETE_HEADER_BACKGROUND = 'fr-background-alt--grey'.freeze

  # @label 1. Avec formulaire et instructeur
  #
  # Cas le plus courant : la demande est passée par un formulaire et a été validée par un
  # instructeur, dont le nom est rappelé.
  #
  # **Où** : bas du bandeau d’en-tête d’une habilitation, visible seulement dans l’espace
  # instruction (`policy([:instruction, request]).show?`).
  def with_form_and_instructor
    authorization = Authorization.joins(:approve_authorization_request_event)
      .where.not(form_uid: nil)
      .first!

    render_in_header(authorization)
  end

  # @label 2. Sans formulaire
  #
  # Habilitation sans `form_uid` : la phrase se limite à la demande d’origine et à l’instructeur,
  # sans mention de formulaire.
  #
  # **Où** : bas du bandeau d’en-tête d’une habilitation, visible seulement dans l’espace
  # instruction (`policy([:instruction, request]).show?`).
  def without_form
    authorization = Authorization.where(form_uid: nil, parent_authorization_id: nil).first!

    render_in_header(authorization)
  end

  # @label 3. Auto-générée
  #
  # Habilitation FranceConnect délivrée automatiquement à l’approbation d’une demande API
  # Particulier : l’instructeur est repris de l’habilitation parente.
  #
  # **Où** : bas du bandeau d’en-tête d’une habilitation, visible seulement dans l’espace
  # instruction (`policy([:instruction, request]).show?`).
  def auto_generated
    authorization = Authorization.where.not(parent_authorization_id: nil).first!

    render_in_header(authorization)
  end

  # @label 4. Obsolète (en-tête gris)
  #
  # Même phrase, mais sur le fond gris que prend l’en-tête pour les états obsolète et révoqué. Le
  # composant garde sa couleur de texte blanche : le texte devient illisible (#f5f5fe sur #f6f6f6,
  # contraste 1,01:1).
  #
  # **Où** : bas du bandeau d’en-tête d’une habilitation, visible seulement dans l’espace
  # instruction (`policy([:instruction, request]).show?`).
  def obsolete
    authorization = Authorization.where(state: 'obsolete').first!

    render_in_header(authorization, background_class: OBSOLETE_HEADER_BACKGROUND)
  end

  private

  def render_in_header(authorization, background_class: ACTIVE_HEADER_BACKGROUND)
    render_with_template(
      template: 'habilitation/origin_header_info_preview/in_header',
      locals: { authorization:, background_class: }
    )
  end
end
