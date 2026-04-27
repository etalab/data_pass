module Instruction::UserRightsHelper
  ROLE_BADGE_COLORS = {
    'manager' => 'purple-glycine',
    'instructor' => 'pink-tuile',
    'reporter' => 'yellow-tournesol',
    'developer' => 'blue-ecume',
  }.freeze

  def role_badge(role_type)
    color = ROLE_BADGE_COLORS.fetch(role_type)

    content_tag(
      :p,
      t("instruction.user_rights.roles.#{role_type}"),
      class: "fr-badge fr-badge--sm fr-badge--#{color} fr-badge--no-icon"
    )
  end
end
