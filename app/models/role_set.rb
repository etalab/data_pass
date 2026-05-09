class RoleSet
  def initialize(user_roles_relation, kind)
    @roles = user_roles_relation.effective_for_role(kind)
  end

  def covers?(definition_id = nil)
    return @roles.exists? unless definition_id

    @roles.effective_for_definition(definition_id).exists?
  end

  def any?
    @roles.exists?
  end

  def definition_ids
    @definition_ids ||= @roles.flat_map(&:covered_definition_ids).compact.uniq
  end

  def authorization_request_types
    definition_ids.map { |id| "AuthorizationRequest::#{id.classify}" }
  end

  def authorization_definitions
    definition_ids.filter_map { |id| AuthorizationDefinition.find_by(id: id) }
  end
end
