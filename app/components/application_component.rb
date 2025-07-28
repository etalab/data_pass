class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper

  delegate :policy, to: :helpers
end
