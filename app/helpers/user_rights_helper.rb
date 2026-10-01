module UserRightsHelper
  ROLE_FILTER_TYPES = %w[manager instructor developer reporter].freeze
  ADMIN_ONLY_FILTER_TYPES = %w[admin].freeze

  def user_rights_search_status_message(users, search_term, filtered: false)
    return t('instruction.user_rights.index.users_count', count: users.total_count) unless users.empty?

    if search_term.present? || filtered
      t('instruction.user_rights.index.no_results')
    else
      t('instruction.user_rights.index.empty_state')
    end
  end

  ROLE_PRESENCE_FILTERS = %w[with_roles without_roles].freeze

  def user_rights_role_filter_options(admin_view: false)
    types = ROLE_FILTER_TYPES + (admin_view ? ADMIN_ONLY_FILTER_TYPES : [])

    presence_options(admin_view) + types.map { |role| [t("instruction.user_rights.roles.#{role}"), role] }
  end

  def presence_options(admin_view)
    return [] unless admin_view

    ROLE_PRESENCE_FILTERS.map { |key| [t("instruction.user_rights.index.filters.role.#{key}"), key] }
  end

  def user_rights_droit_filter_options(authority)
    authority.managed_definitions
      .select(&:name)
      .sort_by(&:name_with_stage)
      .map { |definition| [definition.name_with_stage, definition.id] }
  end
end
