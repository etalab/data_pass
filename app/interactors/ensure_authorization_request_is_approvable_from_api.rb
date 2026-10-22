class EnsureAuthorizationRequestIsApprovableFromAPI < ApplicationInteractor
  def call
    return if context.authorization_request.submitted? && approvable_by_instructor?

    fail_with_error(:not_approvable_from_api)
  end

  private

  def approvable_by_instructor?
    Instruction::AuthorizationRequestPolicy.new(
      UserContext.new(context.user),
      context.authorization_request
    ).approve?
  end
end
