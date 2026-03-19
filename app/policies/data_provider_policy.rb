class DataProviderPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    update?
  end

  def update?
    user.admin?
  end

  def confirm_destroy?
    destroy?
  end

  def destroy?
    user.admin? && record.deletable?
  end
end
