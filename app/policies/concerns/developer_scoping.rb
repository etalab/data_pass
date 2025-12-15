module DeveloperScoping
  extend ActiveSupport::Concern

  private

  def user_is_developer_for_definition?(definition_id)
    return false if definition_id.blank?

    user.authorization_definition_roles_as(:developer).any? do |definition|
      definition.id == definition_id
    end
  end

  def developer_definition_ids
    user.authorization_definition_roles_as(:developer).map(&:id)
  end
end
