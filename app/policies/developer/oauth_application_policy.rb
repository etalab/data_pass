class Developer::OauthApplicationPolicy < ApplicationPolicy
  def index?
    user.developer?
  end

  def create?
    user.developer?
  end

  def show_credentials?
    user.developer? && record.owner == user
  end

  def destroy?
    user.developer? && record.owner == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(owner: user)
    end
  end
end
