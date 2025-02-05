class NewAuthorizationRequest
  class APIINFINOEFacade < Base
    def public_available_without_editor_forms
      AuthorizationRequestFormDecorator.decorate_collection(authorization_definition_sandbox.public_available_forms)
    end

    def public_available_editor_forms
      AuthorizationRequestFormDecorator.decorate_collection(authorization_definition.public_available_forms.select { |form| form.uid.ends_with?('editeur') })
    end

    private

    def authorization_definition_sandbox
      AuthorizationDefinition.find('api_infinoe_sandbox')
    end
  end
end
