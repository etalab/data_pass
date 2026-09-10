module UserRightsHelper
  ROLE_FILTER_TYPES = %w[manager instructor developer reporter admin].freeze

  def user_rights_search_status_message(users, search_term, filtered: false)
    return t('instruction.user_rights.index.users_count', count: users.total_count) unless users.empty?

    if search_term.present? || filtered
      t('instruction.user_rights.index.no_results')
    else
      t('instruction.user_rights.index.empty_state')
    end
  end

  ROLE_PRESENCE_FILTERS = %w[with_roles without_roles].freeze

  def user_rights_role_filter_options(presence: false)
    presence_options(presence) + ROLE_FILTER_TYPES.map { |role| [t("instruction.user_rights.roles.#{role}"), role] }
  end

  def presence_options(presence)
    return [] unless presence

    ROLE_PRESENCE_FILTERS.map { |key| [t("instruction.user_rights.index.filters.role.#{key}"), key] }
  end

  def user_rights_droit_filter_options(authority)
    authority.managed_definitions
      .select(&:name)
      .sort_by(&:name_with_stage)
      .map { |definition| [definition.name_with_stage, definition.id] }
  end
end
