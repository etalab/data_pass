class WebhookSerializer
  attr_reader :authorization_request,
    :event,
    :extra_data

  def initialize(authorization_request, event)
    @authorization_request = authorization_request
    @event = event
  end

  def serializable_hash
    {
      event:,
      fired_at: now.to_i,
      model_type: authorization_request.type.underscore,
      model_id: authorization_request.id,
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
      include: %w[applicant organization service_provider]
    )
  end
end
