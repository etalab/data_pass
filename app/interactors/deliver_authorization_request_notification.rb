class DeliverAuthorizationRequestNotification < ApplicationInteractor
  def call
    notifier_klass.new(context.authorization_request).public_send(
      event_name,
      params,
    )
  end

  private

  def event_name
    context.state_machine_event ||
      context.event_name
  end

  def params
    context.authorization_request_notifier_params || {}
  end

  def notifier_klass
    "#{context.authorization_request.class_name.demodulize}Notifier".constantize
  rescue NameError
    BaseNotifier
  end
end
