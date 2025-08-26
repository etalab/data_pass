class BaseNotifier < ApplicationNotifier
  notifier_event_names.each do |event_name|
    # rubocop:disable Lint/EmptyBlock
    define_method(event_name) do |_params|
    end
    # rubocop:enable Lint/EmptyBlock
  end

  %w[
    request_changes
    refuse
  ].each do |event|
    define_method(event) do |params|
      email_notification_with_reopening(event, params)
    end
  end

  def approve(params)
    deliver_gdpr_emails

    notify_france_connect if authorization_request.with_france_connect?

    email_notification_with_reopening('approve', params)
  end

  def submit(params)
    email_notification_with_reopening('submit', params, mailer: Instruction::AuthorizationRequestMailer)
  end

  def revoke(params) = email_notification('revoke', params)

  private

  def notify_france_connect
    FranceConnectMailer.with(authorization_request:).new_scopes.deliver_later
  end
end
