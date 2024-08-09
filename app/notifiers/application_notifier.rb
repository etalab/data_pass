class ApplicationNotifier
  attr_reader :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def self.notifier_event_names
    AuthorizationRequest.state_machine.events.map(&:name) + %w[create update transfer]
  end

  notifier_event_names.each do |notifier_event_name|
    define_method(notifier_event_name) do |_params|
      fail NotImplementedError, "You must implement '#{notifier_event_name}' method"
    end
  end

  protected

  def deliver_gdpr_emails
    DeliverGDPRContactsMails.call(authorization_request:)
  end

  def email_notification(event_name, params)
    AuthorizationRequestMailer.with(
      params.merge(
        authorization_request:,
      ),
    ).public_send(event_name).deliver_later
  end

  def webhook_notification(event_name)
    DeliverAuthorizationRequestWebhookJob.new(
      authorization_request.kind,
      webhook_payload(event_name),
      authorization_request.id,
    ).enqueue
  end

  private

  def webhook_payload(event_name)
    WebhookSerializer.new(
      authorization_request,
      event_name
    ).to_json
  end
end
