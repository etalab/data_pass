class AfterUpdateAuthorizationRequestWithChanges < ApplicationInteractor
  def call
    return if context.changelog.nil?

    AfterUpdateAuthorizationRequest.call!(context)
  end
end
