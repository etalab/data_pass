class RecordEmailsVerifiedByProviderOnEvent < ApplicationInteractor
  def call
    return unless context.verified_email

    context.authorization_request_event&.update!(emails_verified_by_provider: true)
  end
end
