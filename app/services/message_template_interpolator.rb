class MessageTemplateInterpolator
  attr_reader :content, :host

  def initialize(content, host: nil)
    @content = content
    @host = host || 'http://localhost:3000'
  end

  def interpolate(object)
    format(content, build_variables(object))
  rescue KeyError
    raise ArgumentError, 'Missing variable in template'
  end

  def valid?(object)
    interpolate(object)
    true
  rescue ArgumentError
    false
  end

  def build_variables(object)
    public_send("build_variables_for_#{extract_object_name(object)}", object)
  end

  def build_variables_for_authorization_request(authorization_request)
    {
      demande_url: authorization_request_url(authorization_request),
      demande_intitule: authorization_request.respond_to?(:intitule) ? authorization_request.intitule : nil,
      demande_id: authorization_request.id
    }
  end

  def authorization_request_url(authorization_request)
    Rails.application.routes.url_helpers.authorization_request_url(
      authorization_request,
      host:
    )
  end

  private

  def extract_object_name(object)
    object.class.name.underscore.split('/').first
  end
end
