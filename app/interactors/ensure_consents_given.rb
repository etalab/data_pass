class EnsureConsentsGiven < ApplicationInteractor
  def call
    missing_consents = context.authorization_request.required_consents.reject { |consent| given?(consent) }

    return if missing_consents.empty?

    fail_with_error(:consent_missing, errors: missing_consents)
  end

  private

  def given?(consent)
    ActiveModel::Type::Boolean.new.cast(context.consentement[consent]) == true
  end
end
