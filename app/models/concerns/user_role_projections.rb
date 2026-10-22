module UserRoleProjections
  extend ActiveSupport::Concern

  def distinct_role_types
    roles.filter_map { |role_string| ParsedRole.parse(role_string).role }.uniq
  end

  def specific_authorization_definitions
    specific_definition_ids.filter_map { |id| AuthorizationDefinition.find_by(id:) }
  end

  def rights_by_definition
    entries = specific_roles.group_by(&:definition_id).filter_map do |definition_id, parsed_roles|
      definition = AuthorizationDefinition.find_by(id: definition_id)
      next unless definition

      { definition: definition, role_types: parsed_roles.map(&:role).uniq }
    end

    entries.sort_by { |entry| entry[:definition].name_with_stage }
  end

  private

  def specific_roles
    roles.filter_map do |role_string|
      parsed = ParsedRole.parse(role_string)
      parsed unless parsed.definition_id.nil? || parsed.fd_level?
    end
  end

  def specific_definition_ids
    specific_roles.map(&:definition_id).uniq
  end
end
