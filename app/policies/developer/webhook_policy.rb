module Developer
  class WebhookPolicy < ApplicationPolicy
    include DeveloperScoping

    def index?
      user.developer?
    end

    def show?
      user_is_developer_for_definition?(record.authorization_definition_id)
    end

    def create?
      user.developer?
    end

    def update?
      user_is_developer_for_definition?(record.authorization_definition_id)
    end

    def destroy?
      user_is_developer_for_definition?(record.authorization_definition_id) && !record.enabled?
    end

    def enable?
      user_is_developer_for_definition?(record.authorization_definition_id) && record.validated? && !record.enabled?
    end

    def disable?
      user_is_developer_for_definition?(record.authorization_definition_id) && record.enabled?
    end

    class Scope < ApplicationPolicy::Scope
      include DeveloperScoping

      def resolve
        return scope.none unless user.developer?

        scope.where(authorization_definition_id: developer_definition_ids)
      end
    end
  end
end
