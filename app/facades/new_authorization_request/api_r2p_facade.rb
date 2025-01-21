class NewAuthorizationRequest
  class APIR2PFacade < Base
    class Choice
      attr_reader :id, :selector

      def initialize(id:, selector:)
        @id = id
        @selector = selector
      end
    end

    def public_available_forms_sandbox
      AuthorizationRequestFormDecorator.decorate_collection(authorization_definition_sandbox.public_available_forms)
    end

    def choices
      [
        Choice.new(id: 'without_editor', selector: "[data-selector='without_editor']"),
        Choice.new(id: 'with_editor', selector: "[data-selector='with_editor']"),
      ]
    end

    private

    def authorization_definition_sandbox
      AuthorizationDefinition.find('api_r2p_sandbox')
    end
  end
end
