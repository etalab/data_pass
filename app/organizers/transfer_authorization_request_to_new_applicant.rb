class TransferAuthorizationRequestToNewApplicant < ApplicationOrganizer
  before do
    context.event_entity = :authorization_request_transfer
    context.event_name = 'transfer'

    context.new_applicant = extract_new_applicant
    context.old_applicant = context.authorization_request.applicant

    context.old_entity = context.old_applicant
    context.new_entity = context.new_applicant
  end

  organize UpdateApplicantOnAuthorizationRequest,
    CreateAuthorizationRequestTransferModel,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification

  private

  def extract_new_applicant
    User.find_by(email: context.new_applicant_email) || email_not_found!
  end

  def email_not_found!
    context.fail!(error: :email_not_found)
  end
end
