class WebhookMailer < ActionMailer::Base
  layout false

  def fail
    @webhook_url = ENV["#{params[:target_api].upcase}_WEBHOOK_URL"]
    @payload = JSON.pretty_generate(params[:payload])
    @webhook_response_body = params[:webhook_response_body]
    @webhook_response_status = params[:webhook_response_status]
    @api_manager_label = api_manager_label

    mail(
      subject: t('.subject', api_manager_label: api_manager_label),
      from: t('mailer.shared.support.email'),
      to: target_api_instructor_emails
    )
  end

  private

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