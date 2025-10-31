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

  def email_notification_with_reopening(base_event, params, mailer: AuthorizationRequestMailer)
    event = params[:within_reopening] ? "reopening_#{base_event}" : base_event

    mailer.with(
      params.merge(
        authorization_request:,
      ),
    ).public_send(event).deliver_later
  end
end
