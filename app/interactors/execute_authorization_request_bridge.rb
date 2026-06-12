class ExecuteAuthorizationRequestBridge < ApplicationInteractor
  def call
    bridge = conventional_bridge || declared_bridge
    return if bridge.nil?

    bridge.perform_later(context.authorization_request, context.state_machine_event)
  end

  private

  def conventional_bridge
    Kernel.const_get(:"#{authorization_request_class}Bridge")
  rescue NameError
    nil
  end

  def declared_bridge
    class_name = fresh_definition.bridge_class_name
    return if class_name.blank?

    bridge = class_name.safe_constantize
    return bridge if bridge && bridge < ApplicationBridge

    notify_unresolvable_bridge(class_name)
    nil
  end

  def fresh_definition
    AuthorizationDefinition.find(context.authorization_request.class.to_s.demodulize.underscore)
  end

  def notify_unresolvable_bridge(class_name)
    Sentry.capture_message(
      "ExecuteAuthorizationRequestBridge: declared bridge '#{class_name}' " \
      "is not resolvable for authorization request ##{context.authorization_request.id}",
      level: :error,
    )
  end

  def authorization_request_class
    context.authorization_request.class_name.split('::').last
  end
end
