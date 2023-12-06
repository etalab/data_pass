class AuthorizationRequestFormsController < AuthenticatedUserController
  def index
    @authorization_request_forms = AuthorizationRequestForm.where(public: true)
  end
end
