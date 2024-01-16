class ApplicationNotifier
  attr_reader :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  AuthorizationRequest.state_machine.states.each do |state|
    define_method(state.name) do |_params|
      fail NotImplementedError
    end
  end

  protected

  def email_notification(name, params)
    AuthorizationRequestMailer.with(
      params.merge(
        authorization_request:,
      ),
    ).public_send(name).deliver_later
  end
end
