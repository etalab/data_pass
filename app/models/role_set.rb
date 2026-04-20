class RoleSet
  def initialize(roles_array, kind)
    qualifying = RoleHierarchy.qualifying_roles(kind)
    @matching_roles = roles_array.select do |r|
      parts = r.split(':')
      parts.length == 2 && qualifying.include?(parts[1])
    end
  end

  def covers?(definition_id = nil)
    return @matching_roles.any? unless definition_id

    @matching_roles.any? { |r| r.start_with?("#{definition_id}:") }
  end

  delegate :any?, to: :@matching_roles

  def definition_ids
    @definition_ids ||= @matching_roles.map { |r| r.split(':').first }.uniq
  end

  def authorization_request_types
    definition_ids.map { |id| "AuthorizationRequest::#{id.classify}" }
  end

  def authorization_definitions
    definition_ids.filter_map { |id| AuthorizationDefinition.find_by(id: id) }
  end
end
