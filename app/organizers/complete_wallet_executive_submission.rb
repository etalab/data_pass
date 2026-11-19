class CompleteWalletExecutiveSubmission < ApplicationOrganizer
  organize CheckWalletSubmissionIntent,
    CheckWalletExecutiveCertification,
    SubmitAuthorizationRequest
end
