class WebhookMailer < ApplicationMailer
  def fail
    instanciate_fail_view_variables

    mail(
      subject: t('.subject', authorization_definition_name: @authorization_definition_name),
      from: t('mailer.shared.support.email'),
      to: target_api_instructor_emails
    )
  end

  private

  def instanciate_fail_view_variables
    @webhook_url = Rails.application.credentials.webhooks.public_send(params[:target_api]).url
    @payload = JSON.pretty_generate(params[:payload])
    @webhook_response_body = params[:webhook_response_body]
    @webhook_response_status = params[:webhook_response_status]
    @authorization_definition_name = authorization_definition_name
  end

  def target_api_instructor_emails
    User.instructor_for(params[:target_api]).pluck(:email)
  end

  def authorization_definition_name
    target_api_data.name
  end

  def target_api_data
    AuthorizationDefinition.find(params[:target_api])
  end
end
