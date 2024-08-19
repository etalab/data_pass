class NewAuthorizationRequest
  class DefaultFacade < Base
    def already_integrated_editors
      []
    end

    def editors
      @editors || authorization_definition.editors
    end
  end
end
