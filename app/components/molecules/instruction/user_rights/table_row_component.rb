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

  def own_row?
    user.id == current_user.id
  end

  def editable?
    !own_row? || authority.can_self_edit?
  end
end
