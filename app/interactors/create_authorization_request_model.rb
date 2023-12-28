class CreateAuthorizationRequestModel < ApplicationInteractor
  def call
    context.authorization_request = authorization_request_class.create(authorization_request_create_params)
  end

  private

  def authorization_request_class
    context.authorization_request_form.authorization_request_class
  end

  def authorization_request_create_params
    {
      applicant: context.user,
      organization: context.user.current_organization,
      form_uid: context.authorization_request_form.uid,
    }
  end
end
