class AssignConsentsToAuthorizationRequest < ApplicationInteractor
  include APIConsents

  def call
    context.authorization_request.assign_attributes(consents_given)
  end

  private

  def consents_given
    context.authorization_request.required_consents.index_with { |consent| consent_given?(consent) }
  end
end
