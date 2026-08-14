module UserRoleProjections
  extend ActiveSupport::Concern

  def distinct_role_types
    roles.filter_map { |role_string| ParsedRole.parse(role_string).role }.uniq
  end

  def specific_authorization_definitions
    specific_definition_ids.filter_map { |id| AuthorizationDefinition.find_by(id:) }
  end

  private

  def specific_definition_ids
    roles.filter_map { |role_string|
      parsed = ParsedRole.parse(role_string)
      parsed.definition_id unless parsed.definition_id.nil? || parsed.fd_level?
    }.uniq
  end
end
