class ApplicationBridge < ApplicationJob
  include KeepTrackOfJobAttempts

  THRESHOLD_TO_TRACK_ERROR = 5

  attr_reader :authorization_request

  retry_on(StandardError, wait: :polynomially_longer, attempts: :unlimited)

  def perform(authorization_request, event)
    @authorization_request = authorization_request
    send(:"on_#{event}")
  rescue StandardError => e
    track_error(e) if attempts == THRESHOLD_TO_TRACK_ERROR
    raise
  end

  def on_approve
    fail ::NotImplementedError
  end

  def on_revoke; end

  def track_error(exception)
    Sentry.add_breadcrumb(
      Sentry::Breadcrumb.new(
        data: { authorization_request_id: authorization_request.id },
        message: "Error on #{self.class.name} with authorization_request_id: #{authorization_request.id}",
        category: 'error',
      )
    )

    Sentry.capture_exception(exception)
  end
end
