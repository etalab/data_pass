class Molecules::Instruction::UserRights::ReadonlyRightsListComponent < ApplicationComponent
  def initialize(rights:)
    @rights = rights
  end

  def render?
    rights.any?
  end

  private

  attr_reader :rights

  def grouped_rights
    rights.group_by { |right| right[:role_type] }
  end

  def alert_message(role_type)
    t(
      "instruction.user_rights.edit.readonly_alerts.#{role_type}",
      default: t('instruction.user_rights.edit.readonly_alerts.default')
    )
  end

  def scope_labels(role_type_rights)
    role_type_rights.filter_map do |right|
      Instruction::Scope.new(right[:scope]).label if right[:scope].present?
    end
  end
end
