class ApplicationBridge < ApplicationJob
  attr_reader :authorization_request

  def perform(_authorization_request)
    fail ::NotImplementedError
  end
end
