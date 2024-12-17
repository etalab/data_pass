class NewAuthorizationRequest
  class APIImpotParticulierFacade < Base
    def public_available_forms_sandbox
      AuthorizationRequestFormDecorator.decorate_collection(authorization_definition_sandbox.public_available_forms)
    end

    private

    def authorization_definition_sandbox
      AuthorizationDefinition.find('api_impot_particulier_sandbox')
    end
  end
end
