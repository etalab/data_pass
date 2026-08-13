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

  def user_rights_role_filter_options
    ROLE_FILTER_TYPES.map { |role| [t("instruction.user_rights.roles.#{role}"), role] }
  end

  def user_rights_droit_filter_options(authority)
    presence = %w[with without].map { |key| [t("instruction.user_rights.index.filters.droit.#{key}"), key] }
    definitions = authority.managed_definitions
      .select(&:name)
      .sort_by(&:name)
      .map { |definition| [definition.name, definition.id] }

    presence + definitions
  end
end
