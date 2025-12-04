module Developer
  class WebhookAttemptPolicy < ApplicationPolicy
    include DeveloperScoping

    def index?
      user_is_developer_for_definition?(record.webhook.authorization_definition_id)
    end

    def show?
      user_is_developer_for_definition?(record.webhook.authorization_definition_id)
    end

    def replay?
      user_is_developer_for_definition?(record.webhook.authorization_definition_id)
    end

    class Scope < ApplicationPolicy::Scope
      include DeveloperScoping

      def resolve
        return scope.none unless user.developer?

        scope.joins(:webhook).where(webhooks: { authorization_definition_id: developer_definition_ids })
      end
    end
  end
end
