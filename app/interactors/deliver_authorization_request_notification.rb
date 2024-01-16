class DeliverAuthorizationRequestNotification < ApplicationInteractor
  def call
    notifier_klass.new(context.authorization_request).public_send(
      current_authorization_request_state,
      params,
    )
  end

  private

  def current_authorization_request_state
    context.authorization_request.state
  end

  def params
    context.authorization_request_notifier_params || {}
  end

  def notifier_klass
    "#{context.authorization_request.class.name.demodulize}Notifier".constantize
  rescue NameError
    BaseNotifier
  end
end
