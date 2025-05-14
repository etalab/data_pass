class NewAuthorizationRequest
  class APIEntrepriseFacade < Base
    ALREADY_INTEGRATED_EDITORS = %w[achatpublic actradis arnia atline_services aws_achat axyus dematis entr_ouvert klekoon maximilien megalis_bretagne pictav_informatique smartglobal solution_attestations].freeze

    def public_available_forms
      super.reject do |form|
        form.uid == 'api-entreprise'
      end
    end

    def already_integrated_editors
      @already_integrated_editors ||= ServiceProvider.editors.select do |editor|
        ALREADY_INTEGRATED_EDITORS.include?(editor.id)
      end
    end

    def decorated_editors
      @decorated_editors ||= ServiceProviderDecorator.decorate_collection(sorted_editors, context: { scope: :api_entreprise })
    end

    def editors
      authorization_definition.editors + already_integrated_editors
    end
  end
end
