class ExecuteAuthorizationRequestBridge < ApplicationInteractor
  def call
    return unless bridge_exists?

    bridge.perform_later(context.authorization_request, context.state_machine_event)
  end

  private

  def bridge_exists?
    bridge.present?
  end

  def bridge
    Kernel.const_get(:"#{authorization_request_class}Bridge")
  rescue NameError
    nil
  end

  def authorization_request_class
    context.authorization_request.class.name.split('::').last
  end
end
