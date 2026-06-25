class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper

  delegate :policy, :policy_scope, to: :helpers
end
