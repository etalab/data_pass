class Instruction::UserRightPolicy < ApplicationPolicy
  def enabled?
    user.manager?
  end

  def index?
    enabled?
  end

  def new?
    enabled?
  end

  def create?
    enabled?
  end

  def edit?
    enabled? && record != user && can_manage_any_role?(record)
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def confirm_destroy?
    destroy?
  end

  private

  def can_manage_any_role?(target_user)
    target_user.roles.any? { |role| user.manages_role?(role) }
  end
end
