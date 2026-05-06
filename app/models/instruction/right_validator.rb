class Instruction::RightValidator
  def initialize(rights, permissions)
    @rights = rights
    @permissions = permissions
  end

  def errors
    return [%i[base at_least_one_right]] if no_right_filled?
    return [%i[rights incomplete_right]] if partially_filled?

    [role_type_error, scope_error].compact
  end

  private

  attr_reader :rights, :permissions

  def no_right_filled?
    rights.none? { |r| r[:scope].present? || r[:role_type].present? }
  end

  def partially_filled?
    rights.any? { |r| r[:scope].blank? || r[:role_type].blank? }
  end

  def role_type_error
    return if rights.all? { |r| permissions.allowed_role_types.include?(r[:role_type]) }

    %i[rights role_type_not_allowed]
  end

  def scope_error
    return if rights.all? { |r| permissions.authorized_scopes.include?(r[:scope]) }

    %i[rights scope_not_authorized]
  end
end
