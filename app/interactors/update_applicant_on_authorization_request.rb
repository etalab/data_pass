class UpdateApplicantOnAuthorizationRequest < ApplicationInteractor
  def call
    context.authorization_request.applicant = context.new_applicant

    return if context.authorization_request.save

    context.fail!(error: :invalid_new_applicant)
  end

  def rollback
    context.authorization_request.applicant = context.old_applicant
    context.authorization_request.save
  end
end
