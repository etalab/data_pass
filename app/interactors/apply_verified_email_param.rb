class ApplyVerifiedEmailParam < ApplicationInteractor
  ACCEPTED_VALUES = [nil, true, false, 'true', 'false'].freeze

  def call
    return fail_with_error(:invalid_verified_email) unless ACCEPTED_VALUES.include?(context.verified_email)

    context.verified_email = context.verified_email.to_s == 'true'
    context.authorization_request.emails_verified_by_provider = context.verified_email
  end
end
