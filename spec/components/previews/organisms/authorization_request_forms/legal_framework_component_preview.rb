# frozen_string_literal: true

module Organisms
  module AuthorizationRequestForms
    class LegalFrameworkComponentPreview < ViewComponent::Preview
      def default
        authorization_request = AuthorizationRequest::APIEntreprise.first
        form = create_form_builder(authorization_request)

        render Organisms::AuthorizationRequestForms::LegalFrameworkComponent.new(
          form: form,
          field_prefix: 'cadre_juridique'
        )
      end

      def api_part_france_connect
        authorization_request = AuthorizationRequest::APIParticulier.first
        authorization_request.data ||= {}
        authorization_request.data['modalities'] = ['france_connect']

        form = create_form_builder(authorization_request)

        render Organisms::AuthorizationRequestForms::LegalFrameworkComponent.new(
          form: form,
          field_prefix: 'fc_cadre_juridique'
        )
      end

      private

      def create_form_builder(authorization_request)
        AuthorizationRequestFormBuilder.new(
          :authorization_request,
          authorization_request,
          ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil),
          {}
        )
      end
    end
  end
end
