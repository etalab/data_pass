class ApplicationPolicy
  attr_reader :record, :user_context

  def initialize(user_context, record)
    @user_context = user_context
    @record = record
  end

  delegate :user, to: :user_context
  delegate :authentication_session, to: :user_context

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  delegate :current_organization, to: :user, allow_nil: true

  class Scope
    include SubdomainsHelper

    attr_reader :user_context, :scope

    delegate :current_organization, to: :user

    def initialize(user_context, scope)
      @user_context = user_context
      @scope = scope
    end

    delegate :user, to: :user_context
    delegate :host, to: :user_context

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end
  end
end
