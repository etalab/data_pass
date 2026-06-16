module UserRightsHelper
  def user_rights_search_status_message(users, search_term)
    return t('instruction.user_rights.index.users_count', count: users.total_count) unless users.empty?

    if search_term.present?
      t('instruction.user_rights.index.no_results')
    else
      t('instruction.user_rights.index.empty_state')
    end
  end
end
