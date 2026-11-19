class CheckWalletSubmissionIntent < ApplicationInteractor
  def call
    return if submission_intent&.valid_for?(authorization_request: context.authorization_request, user: context.user, nonce: context.nonce)

    fail_with_error(:wallet_submission_intent_invalid)
  end

  private

  def submission_intent
    context.submission_intent
  end
end
