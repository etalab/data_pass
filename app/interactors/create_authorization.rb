class CreateAuthorization < ApplicationInteractor
  def call
    context.authorization = authorization_request.authorizations.create!(
      authorization_params
    )
  end

  private

  def authorization_request
    context.authorization_request
  end

  def authorization_params
    {
      data: authorization_request.data,
      applicant: authorization_request.applicant,
    }
  end
end
