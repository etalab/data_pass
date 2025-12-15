class WebhookMailer < ApplicationMailer
  def fail
    instanciate_fail_view_variables

    mail(
      subject: t('.subject', authorization_definition_name: @authorization_definition_name),
      from: t('mailer.shared.support.email'),
      to: developer_emails
    )
  end

  private

  def instanciate_fail_view_variables
    @webhook = params[:webhook]
    @webhook_url = @webhook.url
    @webhook_attempts_url = developers_webhook_webhook_attempts_url(@webhook)
    @authorization_definition_name = authorization_definition_name
  end

  def developer_emails
    User.developer_for(@webhook.authorization_definition_id).pluck(:email)
  end

  def authorization_definition_name
    AuthorizationDefinition.find(@webhook.authorization_definition_id).name
  end
end
