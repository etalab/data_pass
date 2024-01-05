class CreateDenialOfAuthorizationModel < ApplicationInteractor
  def call
    context.denial_of_authorization = authorization_request.build_denial(
      denial_of_authorization_params
    )

    return if context.denial_of_authorization.save

    context.fail!
  end

  private

  def authorization_request
    context.authorization_request
  end

  def denial_of_authorization_params
    context.denial_of_authorization_params
  end
end
