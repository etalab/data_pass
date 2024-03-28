class WebhookSerializer
  attr_reader :authorization_request,
    :event,
    :extra_data

  def initialize(authorization_request, event, extra_data = {})
    @authorization_request = authorization_request
    @event = event
    @extra_data = extra_data
  end

  def serializable_hash
    {
      event:,
      fired_at: now.to_i,
      model_type:,
      data: {
        pass: authorization_request_serialized
      }.merge(extra_data)
    }
  end

  def to_json(*_args)
    serializable_hash.to_json
  end

  private

  def model_type
    "enrollment/#{authorization_request.type.underscore.split('/').last}"
  end

  def now
    @now ||= Time.zone.now
  end

  def authorization_request_serialized
    WebhookAuthorizationRequestSerializer.new(authorization_request).serializable_hash
  end
end
