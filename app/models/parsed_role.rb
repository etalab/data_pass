ParsedRole = Data.define(:provider_slug, :definition_id, :role) do
  def self.parse(role_string)
    return new(provider_slug: nil, definition_id: nil, role: 'admin') if role_string == 'admin'

    parts = role_string.split(':')
    return self::NULL unless parts.length == 3

    new(provider_slug: parts[0], definition_id: parts[1], role: parts[2])
  end

  def self.valid?(role_string)
    parsed = parse(role_string)
    return false unless parsed.role
    return true if parsed.admin?
    return false unless User::ROLES.include?(parsed.role)

    parsed.valid_definition?
  end

  def self.resolve_provider_slug(definition_id)
    AuthorizationDefinition.find_by(id: definition_id)&.provider_slug
  end

  def fd_level?
    definition_id == '*'
  end

  def admin?
    role == 'admin'
  end

  def valid_definition?
    if fd_level?
      AuthorizationDefinition.all.any? { |ad| ad.provider_slug == provider_slug }
    else
      self.class.resolve_provider_slug(definition_id) == provider_slug
    end
  end
end

ParsedRole::NULL = ParsedRole.new(provider_slug: nil, definition_id: nil, role: nil)

class ParsedRole::UnknownDefinitionError < StandardError; end
