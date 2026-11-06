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
    enabled? && authority.edits?(record)
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

  def droits?
    enabled? && authority.sees?(record)
  end

  private

  def authority
    @authority ||= Rights::ManagerAuthority.new(user)
  end
end
