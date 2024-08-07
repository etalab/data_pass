class BaseNotifier < ApplicationNotifier
  notifier_event_names.each do |event_name|
    # rubocop:disable Lint/EmptyBlock
    define_method(event_name) do |params|
    end
    # rubocop:enable Lint/EmptyBlock
  end

  %w[
    request_changes
    refuse
  ].each do |event|
    define_method(event) do |params|
      if authorization_request.already_been_validated?
        email_notification("reopening_#{event}", params)
      else
        email_notification(event, params)
      end
    end
  end

  def approve(params)
    deliver_gdpr_emails

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
end
