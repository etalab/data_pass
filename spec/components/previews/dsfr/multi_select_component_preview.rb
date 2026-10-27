# @label Liste à choix multiples
#
# Liste déroulante où l’on coche plusieurs valeurs, avec « Tout sélectionner » et un résumé du choix
# (« 2 sélectionnés »). Le composant rend aussi un `select multiple` natif, envoyé avec le formulaire
# quand JavaScript ne tourne pas.
#
# **Où** : tableau de bord instructeur, dans la barre de filtres des onglets « Demandes »
# (`instruction/dashboard/_authorization_requests`) et « Habilitations »
# (`instruction/dashboard/_authorizations`) : filtre de statut et filtre de type.
#
# **Quand** : à chaque affichage du tableau de bord ; les valeurs cochées sont celles du dernier
# filtrage, relues dans l’adresse (`search_query[…]`). Le filtre de type n’apparaît que si la
# personne suit plus d’un type d’habilitation.
#
# Le code accepte aussi des groupes d’options et des options désactivées, mais aucune vue ne s’en
# sert : ils n’ont donc pas de scénario.
#
# Piège : le layout des aperçus (`layouts/component_preview`) charge `application.js` comme un
# script classique, sans l’importmap ; le navigateur le refuse dès son premier `import`, donc le
# contrôleur Stimulus `dsfr-multi-select` ne tourne pas dans Lookbook. Seul le `select` natif
# s’affiche ; toute la liste déroulante, résumé compris, reste masquée et n’est visible que dans
# l’onglet HTML.
class Dsfr::MultiSelectComponentPreview < ApplicationPreview
  # @label 1. Statut des demandes, aucune sélection
  #
  # État d’arrivée sur l’onglet : rien n’est coché, le résumé (onglet HTML) affiche « Tous les
  # statuts (sauf Supprimée) ».
  #
  # **Où** : tableau de bord instructeur, onglet « Demandes », filtre « Statut ».
  def request_states_none_selected
    render request_states_select(selected: [])
  end

  # @label 2. Statut des demandes, une valeur
  #
  # Une seule valeur cochée : le résumé (onglet HTML) reprend son libellé, « En cours
  # d’instruction ».
  #
  # **Où** : tableau de bord instructeur, onglet « Demandes », filtre « Statut ».
  def request_states_one_selected
    render request_states_select(selected: %w[submitted])
  end

  # @label 3. Statut des habilitations, plusieurs valeurs
  #
  # Deux valeurs cochées, « Active » et « Révoquée » : le résumé (onglet HTML) devient « 2
  # sélectionnés ».
  #
  # **Où** : tableau de bord instructeur, onglet « Habilitations », filtre « Statut ».
  def authorization_states_several_selected
    render Dsfr::MultiSelectComponent.new(
      name: 'search_query[state_in][]',
      options: Authorization.state_machine.states.map { |state| [I18n.t("authorization.states.#{state.name}"), state.name.to_s] },
      selected: %w[active revoked],
      label: I18n.t('instruction.dashboard.authorizations.state_filter_label'),
      placeholder: I18n.t('instruction.dashboard.authorizations.all_status'),
      id: 'search_query_state_in'
    )
  end

  # @label 4. Type d’habilitation, une valeur
  #
  # Les types suivis par l’instructrice multi-fournisseurs (`instructeur-multi-fd@yopmail.com`),
  # le premier coché.
  #
  # **Où** : tableau de bord instructeur, onglet « Habilitations », filtre « Type d’habilitation »,
  # affiché seulement au-delà d’un type suivi.
  def authorization_types_one_selected
    render Dsfr::MultiSelectComponent.new(
      name: 'search_query[authorization_request_class_in][]',
      options: multi_provider_instructor_type_options,
      selected: multi_provider_instructor_type_options.first.last,
      label: I18n.t('instruction.dashboard.authorizations.type_filter_label'),
      placeholder: I18n.t('instruction.dashboard.authorizations.all_types'),
      id: 'search_query_authorization_request_class_in'
    )
  end

  # @label 5. Type de demande, aucune sélection
  #
  # Mêmes types que le scénario 4, rien de coché : le résumé (onglet HTML) affiche « Tous les
  # types de demandes ». Seuls le libellé, le texte d’attente et le nom du paramètre (`type_in`)
  # diffèrent de l’onglet « Habilitations ».
  #
  # **Où** : tableau de bord instructeur, onglet « Demandes », filtre « Type de demande », affiché
  # seulement au-delà d’un type suivi.
  def request_types_none_selected
    render Dsfr::MultiSelectComponent.new(
      name: 'search_query[type_in][]',
      options: multi_provider_instructor_type_options,
      selected: [],
      label: I18n.t('instruction.dashboard.authorization_requests.type_filter_label'),
      placeholder: I18n.t('instruction.dashboard.authorization_requests.all_types'),
      id: 'search_query_type_in'
    )
  end

  private

  def request_states_select(selected:)
    Dsfr::MultiSelectComponent.new(
      name: 'search_query[state_in][]',
      options: request_state_options,
      selected:,
      label: I18n.t('instruction.dashboard.authorization_requests.state_filter_label'),
      placeholder: I18n.t('instruction.dashboard.authorization_requests.all_status'),
      id: 'search_query_state_in'
    )
  end

  def request_state_options
    AuthorizationRequest.state_machine.states
      .reject { |state| state.name == :validated }
      .map { |state| [I18n.t("authorization_request.status.#{state.name}"), state.name.to_s] }
  end

  def multi_provider_instructor_type_options
    User.find_by!(email: 'instructeur-multi-fd@yopmail.com')
      .authorization_definition_roles_as(:reporter)
      .map { |definition| [definition.name_with_stage, definition.authorization_request_class.to_s] }
  end
end
