class RoleSet
  def initialize(roles_array, kind)
    qualifying = RoleHierarchy.qualifying_roles(kind)
    @roles = roles_array.filter_map do |r|
      parsed = ParsedRole.parse(r)
      parsed if qualifying.include?(parsed.role)
    end
  end

  def covers?(definition_id = nil)
    return @roles.any? unless definition_id

    fd_slug = ParsedRole.resolve_provider_slug(definition_id)

    @roles.any? do |parsed|
      parsed.definition_id == definition_id || (parsed.fd_level? && parsed.provider_slug == fd_slug)
    end
  end

  delegate :any?, to: :@roles

  def definition_ids
    @definition_ids ||= @roles.flat_map { |parsed|
      if parsed.fd_level?
        AuthorizationDefinition.all
          .select { |ad| ad.provider_slug == parsed.provider_slug }
          .map(&:id)
      else
        [parsed.definition_id]
      end
    }.uniq
  end

  def authorization_request_types
    definition_ids.map { |id| "AuthorizationRequest::#{id.classify}" }
  end

  def authorization_definitions
    definition_ids.filter_map { |id| AuthorizationDefinition.find_by(id: id) }
  end
end
