module DeveloperScoping
  extend ActiveSupport::Concern

  private

  def user_is_developer_for_definition?(definition_id)
    return false if definition_id.blank?

    user.roles_for(:developer).covers?(definition_id)
  end

  def developer_definition_ids
    user.definition_ids_for(:developer)
  end
end
