class AuthorizationRequestMailer < ApplicationMailer
  %i[approve refuse request_changes revoke].each do |event|
    [event, "reopening_#{event}"].each do |mth|
      next if mth == 'reopening_revoke'

      define_method(mth) do
        @authorization_request = params[:authorization_request]

        mail(
          to: @authorization_request.applicant.email,
          subject: t(
            '.subject',
            authorization_request_id: @authorization_request.id,
          )
        ) do |format|
          format.text { render "authorization_request_mailer/#{@authorization_request.kind}/#{mth}" }
        rescue ActionView::MissingTemplate
          format.text
        end
      end
    end
  end
end
