class EnsureAuthorizationRequestCanBeCreated < ApplicationInteractor
  def call
    violation = rules.creation_violation

    fail_with_error(violation) if violation
  end

  private

  def rules
    AuthorizationRequestCreationRules.for_form(
      context.authorization_request_form,
      organization: context.organization,
      applicant: context.applicant
    )
  end
end
