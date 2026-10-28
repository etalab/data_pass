class EnsureApplicantIsNotBanned < ApplicationInteractor
  def call
    return unless context.authorization_request.applicant.banned?

    fail_with_error(:applicant_banned)
  end
end
