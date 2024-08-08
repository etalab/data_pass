class ApplicationBridge < ApplicationJob
  attr_reader :authorization_request

  retry_on(StandardError, wait: :polynomially_longer, attempts: :unlimited)

  def perform(authorization_request, event)
    @authorization_request = authorization_request
    send(:"on_#{event}")
  end

  def on_approve
    fail ::NotImplementedError
  end

  def on_revoke; end
end
