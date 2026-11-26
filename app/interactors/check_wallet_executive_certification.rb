class CheckWalletExecutiveCertification < ApplicationInteractor
  def call
    return if certified_since_the_click?

    fail_with_error(:wallet_executive_not_certified)
  end

  private

  def certified_since_the_click?
    context.submission_intent.certified_after_issue?(dirigeant_verified_at)
  end

  def dirigeant_verified_at
    context.user.organizations_users.find_by(organization: context.authorization_request.organization)&.dirigeant_verified_at
  end
end
