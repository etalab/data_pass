# @label Éditeur de données (scopes)
#
# Liste répétable de données demandables : nom, valeur et groupe, avec un bouton « Supprimer » par
# ligne et un bouton « Ajouter un scope » en bas.
#
# **Où** : admin > Types d’habilitation > formulaire (création, modification, consultation), section
# « Données (scopes) », dans `Organisms::Admin::HabilitationTypeFormComponent`.
#
# **Pour qui** : administratrices et administrateurs uniquement
# (`AdminController#check_user_is_admin!`). La section est enveloppée dans le contrôleur Stimulus
# `blocks-toggle` (`block-name: scopes`) : elle n’apparaît que si le bloc « Données » est coché plus
# haut dans le formulaire.
#
# Trois niveaux de verrouillage, portés par le même argument `disabled` : ouvert ; `:structural`
# (`structural_fields_locked?`), qui fige la seule colonne « Valeur » — resoumise en champ caché —
# et retire le bouton « Supprimer », le nom et le groupe restant modifiables ; et `true`, qui
# désactive tout et masque l’ajout. Les erreurs se lisent à deux endroits : une alerte en tête pour
# les messages globaux, et un message sous chaque champ fautif, repéré par son index de ligne.
class Molecules::Admin::ScopesEditorComponentPreview < ApplicationPreview
  # @label 1. Deux scopes renseignés
  #
  # Cas nominal, éditeur ouvert : deux lignes complètes (nom, valeur, groupe), chacune avec son
  # bouton « Supprimer », et le bouton « Ajouter un scope » en bas.
  #
  # **Où** : admin > Types d’habilitation > formulaire, section « Données (scopes) », visible
  # seulement si le bloc « Données » est coché plus haut (Stimulus `blocks-toggle`).
  def with_scopes
    record = HabilitationType.new(
      scopes: [
        { 'name' => 'Revenu fiscal', 'value' => 'rfr', 'group' => 'Revenus' },
        { 'name' => 'Adresse', 'value' => 'adresse', 'group' => 'Coordonnees' },
      ]
    )
    render Molecules::Admin::ScopesEditorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record
    )
  end

  # @label 2. Aucun scope — liste vide
  #
  # Liste vide, telle qu’à la création : seul le bouton « Ajouter un scope » subsiste, ce qui donne
  # à voir le point d’entrée de la saisie.
  #
  # **Où** : admin > Types d’habilitation > formulaire, section « Données (scopes) », visible
  # seulement si le bloc « Données » est coché plus haut (Stimulus `blocks-toggle`).
  def empty
    record = HabilitationType.new(scopes: [])
    render Molecules::Admin::ScopesEditorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record
    )
  end

  # @label 3. Première ligne vide — erreurs de validation
  #
  # Restitution des erreurs à deux endroits : une alerte en tête pour les messages globaux, et un
  # message sous chaque champ fautif de la première ligne, repéré par son index.
  #
  # **Où** : admin > Types d’habilitation > formulaire, section « Données (scopes) », visible
  # seulement si le bloc « Données » est coché plus haut (Stimulus `blocks-toggle`).
  def with_errors
    record = HabilitationType.new(
      blocks: [{ 'name' => 'scopes' }],
      scopes: [
        { 'name' => '', 'value' => '', 'group' => '' },
        { 'name' => 'Adresse', 'value' => 'adresse', 'group' => 'Coordonnees' },
      ]
    )
    record.validate
    render Molecules::Admin::ScopesEditorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record
    )
  end

  private

  def create_form_builder(record)
    DsfrFormBuilder.new(
      :habilitation_type,
      record,
      ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil),
      {}
    )
  end
end
