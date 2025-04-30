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
      if authorization_request.is_reopening?
        email_notification("reopening_#{event}", params)
      else
        email_notification(event, params)
      end
    end
  end

  def approve(params)
    deliver_gdpr_emails

    notify_france_connect if authorization_request.with_france_connect?

    if params[:first_validation]
      email_notification('approve', params)
    else
      email_notification('reopening_approve', params)
    end
  end

  def submit(_params)
    Instruction::AuthorizationRequestMailer.with(
      authorization_request:
    ).submit.deliver_later
  end

  def revoke(params) = email_notification('revoke', params)

  private

  def notify_france_connect
    FranceConnectMailer.with(authorization_request:).new_scopes.deliver_later
  end
end
