class AuthorizationRequestMailer < ApplicationMailer
  def validated
    @authorization_request = params[:authorization_request]

    mail(
      to: @authorization_request.applicant.email,
      subject: t(
        '.subject',
        authorization_request_id: @authorization_request.id,
      )
    )
  end
end
