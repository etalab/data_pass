# frozen_string_literal: true

module Organisms
  module AuthorizationRequestForms
    # @label Cadre juridique (formulaire de demande)
    #
    # Encadré du formulaire de demande consacré au cadre juridique : une zone de texte pour en
    # décrire la nature, puis, séparés par un badge « OU », un dépôt de justificatifs et un champ
    # URL.
    #
    # **Où** : formulaire de demande API Particulier, étape « cadre juridique »
    # (`app/views/authorization_request_forms/blocks/api_particulier/_legal.html.erb`), une première
    # fois pour le cadre juridique général puis une seconde pour le cadre juridique FranceConnect.
    # **Quand** : le second encadré n’apparaît que si la demande passe par FranceConnect
    # (`france_connect_modality?` et `france_connect_certified_form?`), et la vue l’enferme dans un
    # `fieldset disabled` quand la demande est déjà rattachée à une habilitation FranceConnect.
    #
    # Tous les libellés viennent de `form.wording_for("#{field_prefix}…")` : ils changent avec le
    # préfixe, et chaque intitulé dont la traduction manque disparaît silencieusement (les `rescue
    # I18n::MissingTranslationData` renvoient `nil`).
    class LegalFrameworkComponentPreview < ApplicationPreview
      # @label 1. Cadre juridique général
      #
      # Le premier encadré du formulaire, préfixe `cadre_juridique` : zone de texte sur la nature du
      # cadre juridique, puis dépôt de justificatifs et champ URL séparés par le badge « OU ».
      #
      # **Où** : formulaire de demande API Particulier, étape « cadre juridique »
      # (`authorization_request_forms/blocks/api_particulier/_legal`).
      def default
        authorization_request = AuthorizationRequest::APIParticulier.first
        form = create_form_builder(authorization_request)

        render Organisms::AuthorizationRequestForms::LegalFrameworkComponent.new(
          form: form,
          field_prefix: :cadre_juridique
        )
      end

      # @label 2. Cadre juridique FranceConnect
      #
      # Le second encadré, préfixe `fc_cadre_juridique` : mêmes champs, libellés FranceConnect. La
      # modalité `france_connect` est forcée ici pour obtenir le cas que la vue conditionne.
      #
      # La preview le montre toujours modifiable, alors que la vue l’enferme dans un `fieldset
      # disabled` quand la demande est déjà rattachée à une habilitation FranceConnect.
      #
      # **Où** : formulaire de demande API Particulier, étape « cadre juridique », sous le premier
      # encadré, si `france_connect_modality?` et `france_connect_certified_form?`.
      def api_part_france_connect
        authorization_request = AuthorizationRequest::APIParticulier.first
        authorization_request.data ||= {}
        authorization_request.data['modalities'] = ['france_connect']

        form = create_form_builder(authorization_request)

        render Organisms::AuthorizationRequestForms::LegalFrameworkComponent.new(
          form: form,
          field_prefix: :fc_cadre_juridique
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
