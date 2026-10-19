# @label Liste des modifications
#
# Liste à puces des changements apportés à une demande, une ligne par changement : champ modifié
# avec son ancienne et sa nouvelle valeur, ou donnée ajoutée ou retirée. Les lignes sont calculées
# par `DiffPresenter` à partir du `diff` de l’événement.
#
# **Où** : historique d’une demande, sous un événement qui modifie ses données, rendu par
# `HistoricalAuthorizationRequestEventComponent#render_diff_list`. Deux pages l’utilisent :
# `authorization_request_events/index` côté demandeur et
# `instruction/authorization_request_events/index` côté instruction.
#
# **Quand** : deux familles d’événements.
# - Journal des changements, lu par `AuthorizationRequestChangelogPresenter`, sous une soumission
#   (`submit`) ou une création ou mise à jour par l’API (`create_by_api`, `update_by_api`). La liste
#   n’apparaît que si le présentateur classe le journal comme une nouvelle soumission avec
#   changements (`submit_with_changes`, `legacy_submit_with_changes`) ou comme une première
#   soumission qui modifie des données préremplies (`initial_submit_with_changes_on_prefilled_data`) :
#   ce sont des noms calculés, pas des événements enregistrés. Pour `submit`, ce nom calculé est
#   aussi celui affiché. S’y ajoute `admin_update`, historique importé de l’ancienne version de
#   DataPass, qui affiche toutes les données modifiées, sans ce filtrage (`from_admin: true`).
# - Correction par un administrateur depuis la console (`admin_change`, `Admin::CreateAdminChange`).
#
# Le composant ne rend rien quand la liste est vide (`render?`).
#
# Les seeds ne créent ni nouvelle soumission avec changements ni `admin_change` : les scénarios
# appliquent `DiffPresenter` à la demande « Référence — Validée » du compte
# `dem-commune@yopmail.com`, avec un `diff` construit sur ses vraies valeurs.
class DiffListComponentPreview < ApplicationPreview
  # @label 1. Correction d’un champ
  #
  # Un seul champ modifié, avec son ancienne et sa nouvelle valeur : forme d’une correction par un
  # administrateur (`admin_change`), identique pour un champ changé lors d’une nouvelle soumission.
  #
  # **Où** : historique d’une demande, côté demandeur comme côté instruction.
  def field_change
    render_diff(
      'contact_technique_email' => [authorization_request.contact_technique_email, 'technique-clamart@yopmail.com']
    )
  end

  # @label 2. Nouvelle soumission : données demandées ajoutées et retirées
  #
  # Le demandeur soumet à nouveau sa demande après avoir changé les données demandées (`scopes`) :
  # une ligne par donnée ajoutée, puis une ligne par donnée retirée, chacune avec son libellé et sa
  # valeur technique.
  #
  # **Où** : historique d’une demande, côté demandeur comme côté instruction, sous une soumission
  # (`submit`) affichée comme nouvelle soumission avec changements (`submit_with_changes`).
  def scopes_change
    render_diff('scopes' => [current_scopes, updated_scopes])
  end

  private

  def render_diff(diff)
    render DiffListComponent.new(entries: DiffPresenter.new(diff, authorization_request).entries)
  end

  def authorization_request
    @authorization_request ||= AuthorizationRequest.find(Seeds::DemCommuneReferenceRequests::IDS.fetch('Validée'))
  end

  def current_scopes
    authorization_request.scopes
  end

  def updated_scopes
    current_scopes.drop(1) + [unrequested_scope_value]
  end

  def unrequested_scope_value
    authorization_request.available_scopes.map(&:value).excluding(current_scopes).fetch(0)
  end
end
