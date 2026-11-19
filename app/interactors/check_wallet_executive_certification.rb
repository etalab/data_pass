class CheckWalletExecutiveCertification < ApplicationInteractor
  def call
    return if certified_since_the_click?

    fail_with_error(:wallet_executive_not_certified)
  end

  private

  def certified_since_the_click?
    dirigeant_verification = context.dirigeant_verification

    dirigeant_verification.present? &&
      dirigeant_verification.valid_for?(user: context.user, organization: context.authorization_request.organization) &&
      context.submission_intent.certified_after_issue?(dirigeant_verification)
  end
end
