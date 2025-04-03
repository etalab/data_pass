class AuthorizationHeaderComponent < ApplicationComponent
  def initialize(authorization:)
    @authorization = authorization
  end

  private

  attr_reader :authorization
end
