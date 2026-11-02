class WebhookSerializer
  attr_reader :authorization_request,
    :event,
    :extra_data

  def initialize(authorization_request, event, notifications: true, source: nil)
    @authorization_request = authorization_request
    @event = event
    @source = source || 'web'
    @notifications = notifications
  end

  def serializable_hash
    {
      event: event.to_s,
      source: @source,
      fired_at: now.to_i,
      updated_at: authorization_request.updated_at&.iso8601(6),
      model_type: authorization_request.type.underscore,
      model_id: authorization_request.id,
      notifications: @notifications,
      data: authorization_request_serialized,
    }
  end

  def to_json(*_args)
    serializable_hash.to_json
  end

  private

  def now
    @now ||= Time.zone.now
  end

  def authorization_request_serialized
    WebhookAuthorizationRequestSerializer.new(authorization_request).serializable_hash(
      include: %w[applicant organization service_provider authorizations]
    )
  end
end
