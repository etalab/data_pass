class Instruction::MessageTemplatePolicy < ApplicationPolicy
  def index?
    user.instructor? || user.manager?
  end

  def show?
    index? && user_can_access_authorization_definition?
  end

  def create?
    user.manager?
  end

  def new?
    create?
  end

  def update?
    manager_for_record?
  end

  def edit?
    update?
  end

  def destroy?
    manager_for_record?
  end

  def preview?
    show?
  end

  private

  def manager_for_record?
    user.manager?(record.authorization_definition_uid)
  end

  def user_can_access_authorization_definition?
    return false unless record.authorization_definition_uid

    user.instructor?(record.authorization_definition_uid) ||
      user.manager?(record.authorization_definition_uid)
  end

  class Scope < Scope
    def resolve
      scope.where(authorization_definition_uid: accessible_authorization_definition_uids)
    end

    private

    def accessible_authorization_definition_uids
      user.instructor_roles.map { |role| role.split(':').first }
    end
  end
end
