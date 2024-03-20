class WebhookMailer < ApplicationMailer
  layout false

  def fail
    init_fail!

    mail(
      subject: t('.subject', api_manager_label:),
      from: t('mailer.shared.support.email'),
      to: target_api_instructor_emails
    )
  end

  private

  def init_fail!
    @webhook_url = ENV.fetch("#{params[:target_api].upcase}_WEBHOOK_URL", nil)
    @payload = JSON.pretty_generate(params[:payload])
    @webhook_response_body = params[:webhook_response_body]
    @webhook_response_status = params[:webhook_response_status]
    @api_manager_label = api_manager_label
  end

  def target_api_instructor_emails
    User.instructor_for(params[:target_api]).pluck(:email)
  end

  def api_manager_label
    target_api_data.name
  end

  def target_api_data
    AuthorizationDefinition.find(params[:target_api])
  end
end
