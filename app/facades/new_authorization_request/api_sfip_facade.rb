class NewAuthorizationRequest
  class APISFiPFacade < Base
    def public_available_without_editor_forms
      AuthorizationRequestFormDecorator.decorate_collection(authorization_definition_sandbox.public_available_forms)
    end

    def public_available_editor_forms
      AuthorizationRequestFormDecorator.decorate_collection(authorization_definition.public_available_forms.select { |form| form.uid.ends_with?('editeur') })
    end

    def r2p_through_sfip_facade
      @r2p_through_sfip_facade ||= begin
        r2p_definition = AuthorizationDefinition.find('api_sfip_r2p')
        APISFiPR2PFacade.new(authorization_definition: r2p_definition)
      end
    end

    private

    def authorization_definition_sandbox
      AuthorizationDefinition.find('api_sfip_sandbox')
    end
  end
end
