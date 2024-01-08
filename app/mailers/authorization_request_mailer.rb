class AuthorizationRequestMailer < ApplicationMailer
  %i[validated refused changes_requested].each do |status|
    define_method(status) do
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
end
