class CreateAuthorizationRequestTransferModel < ApplicationInteractor
  def call
    context.authorization_request_transfer = AuthorizationRequestTransfer.new(
      authorization_request_transfer_params,
    )

    context.fail!(error: :invalid_transfer) unless context.authorization_request_transfer.save
  end

  private

  def authorization_request_transfer_params
    {
      authorization_request: context.authorization_request,
      from: context.old_applicant,
      to: context.new_applicant
    }
  end
end
