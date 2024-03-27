class AuthorizationRequestMailer < ApplicationMailer
  %i[validated refused changes_requested revoked].each do |state|
    [state, "reopening_#{state}"].each do |mth|
      define_method(mth) do
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
end
