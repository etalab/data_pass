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
    enabled? && record != user && record.managed_by?(user)
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
end
