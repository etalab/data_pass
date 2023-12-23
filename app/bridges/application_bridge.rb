class ApplicationBridge
  attr_reader :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def perform
    fail ::NotImplementedError
  end
end
