class AuthorizationHeaderComponent < ApplicationComponent
  def initialize(authorization:, authorization_request:)
    @authorization = authorization
    @authorization_request = authorization_request
  end

  private

  attr_reader :authorization, :authorization_request
end
