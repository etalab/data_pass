class EnsureConsentsGiven < ApplicationInteractor
  include APIConsents

  def call
    missing_consents = context.authorization_request.required_consents.reject { |consent| consent_given?(consent) }

    return if missing_consents.empty?

    fail_with_error(:consent_missing, errors: missing_consents)
  end
end
