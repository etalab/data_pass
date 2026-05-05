class Rights::Authority
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def allowed_role_types
    raise NotImplementedError
  end

  def authorized_scopes
    @authorized_scopes ||= definition_scopes + fd_scopes
  end

  def managed_definitions
    raise NotImplementedError
  end

  def fd_manager_for?(_provider_slug)
    raise NotImplementedError
  end

  def audit_event_name
    raise NotImplementedError
  end

  private

  def definition_scopes
    managed_definitions.map { |ad| "#{ad.provider_slug}:#{ad.id}" }
  end

  def fd_scopes
    fd_provider_slugs.map { |slug| "#{slug}:*" }
  end

  def fd_provider_slugs
    raise NotImplementedError
  end
end
