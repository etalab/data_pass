class AutoInstructAuthorizationRequest < ApplicationInteractor
  REFUSAL_REASON = 'Refus automatique : au regard de son identité juridique, ' \
                   'votre organisation n’apparaît pas éligible à cette démarche.'.freeze

  def call
    return unless authorization_request.submitted?
    return unless authorization_request.definition.auto_instruction?

    verdict = EntityEligibility::Engine.from_request(authorization_request).verdict

    approve if verdict.eligible?
    refuse if verdict.ineligible?
  end

  private

  def approve
    ApproveAuthorizationRequest.call(authorization_request:, user: system_user)
  end

  def refuse
    RefuseAuthorizationRequest.call(
      authorization_request:,
      user: system_user,
      denial_of_authorization_params: { reason: REFUSAL_REASON },
    )
  end

  def authorization_request
    context.authorization_request
  end

  def system_user
    User.find_or_create_by!(email: 'systeme@datapass.api.gouv.fr')
  end
end
