class WebhookMailer < ApplicationMailer
  def fail
    instanciate_fail_view_variables

    mail(
      subject: t('.subject', authorization_definition_name: @authorization_definition_name),
      from: t('mailer.shared.support.email'),
      to: instructor_emails
    )
  end

  private

  def instanciate_fail_view_variables
    @webhook_url = Rails.application.credentials.webhooks.public_send(params[:authorization_request_kind]).url
    @payload = JSON.pretty_generate(params[:payload])
    @webhook_response_body = params[:webhook_response_body]
    @webhook_response_status = params[:webhook_response_status]
    @authorization_definition_name = authorization_definition_name
  end

  def instructor_emails
    User.instructor_for(params[:authorization_request_kind]).pluck(:email)
  end

  def authorization_definition_name
    AuthorizationDefinition.find(params[:authorization_request_kind]).name
  end
end
