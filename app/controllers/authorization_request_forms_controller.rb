class AuthorizationRequestFormsController < AuthenticatedUserController
  def index
    @authorization_request_forms = AuthorizationRequestForm.indexable
  end
end
