class ApplicationBridge < ApplicationJob
  include KeepTrackOfJobAttempts

  THRESHOLD_TO_TRACK_ERROR = 5
  HTTP_BODY_MAX_LENGTH = 500

  attr_reader :authorization_request, :event

  retry_on(StandardError, wait: :polynomially_longer, attempts: :unlimited)

  def perform(authorization_request, event)
    @authorization_request = authorization_request
    @event = event
    send(:"on_#{event}")
  rescue StandardError => e
    track_error(e) if track_error_now?
    raise
  end

  def on_approve
    fail ::NotImplementedError
  end

  def on_revoke; end

  def track_error(exception)
    Sentry.capture_exception(
      exception,
      tags: { bridge: self.class.name, demande_id: authorization_request.id },
      contexts: { bridge: error_context(exception) },
    )
  end

  private

  def track_error_now?
    attempts == THRESHOLD_TO_TRACK_ERROR
  end

  def error_context(exception)
    {
      demande_id: authorization_request.id,
      evenement: event,
      tentative: attempts,
      http_status: exception.try(:response_status),
      http_body: exception.try(:response_body)&.to_s&.truncate(HTTP_BODY_MAX_LENGTH),
    }.compact
  end
end
