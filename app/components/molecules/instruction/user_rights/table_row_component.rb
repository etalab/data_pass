class Molecules::Instruction::UserRights::TableRowComponent < ApplicationComponent
  ROLE_ORDER = %w[admin manager instructor developer reporter].freeze
  AGGREGATE_THRESHOLD = 2

  def initialize(user:, authority:, current_user:)
    @user = user
    @authority = authority
    @current_user = current_user
  end

  private

  attr_reader :user, :authority, :current_user

  def role_types
    user.distinct_role_types.sort_by { |role_type| ROLE_ORDER.index(role_type) || ROLE_ORDER.size }
  end

  def droits
    @droits ||= user.specific_authorization_definitions.sort_by(&:name_with_stage)
  end

  def aggregate_droits?
    droits.size > AGGREGATE_THRESHOLD
  end

  def specific_roles
    @specific_roles ||= user.roles.filter_map do |role_string|
      parsed = ParsedRole.parse(role_string)
      parsed unless parsed.definition_id.nil? || parsed.fd_level?
    end
  end

  def ambiguous_pairing?
    specific_roles.map(&:role).uniq.size > 1 && specific_roles.map(&:definition_id).uniq.size > 1
  end

  def rights_by_definition
    grouped = specific_roles.group_by(&:definition_id).filter_map do |definition_id, parsed_roles|
      definition = AuthorizationDefinition.find_by(id: definition_id)
      next unless definition

      { definition: definition, role_types: parsed_roles.map(&:role).uniq }
    end

    grouped.sort_by { |entry| entry[:definition].name_with_stage }
  end

  def tooltip_id
    "user-rights-pairing-#{user.id}"
  end

  def own_row?
    user.id == current_user.id
  end

  def editable?
    !own_row? || authority.can_self_edit?
  end
end
