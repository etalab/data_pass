class HabilitationTypePolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
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

  def edit_structural_fields?
    user.admin? && without_requests?
  end

  def destroy?
    user.admin? && without_requests?
  end

  private

  def without_requests?
    record.authorization_requests_count.zero?
  end
end
