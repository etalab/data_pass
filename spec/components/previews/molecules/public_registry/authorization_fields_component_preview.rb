# @label Champs de la fiche d’une habilitation (registre public)
#
# Liste de définitions (`dl`) des huit champs publiés pour une habilitation active, dans cet
# ordre : Organisation habilitée, SIRET, API ou service, Fournisseur, Données demandées, Fondement
# juridique, Date de validation, Numéro au registre (DPP-224, RG1). Chaque couple `dt`/`dd` est une
# ligne de la grille DSFR : libellé sur un tiers, valeur sur deux tiers, puis une seule colonne
# sous 576 px.
#
# **Où** : page publique « Fiche d’une habilitation » du registre public, colonne principale, sous
# l’en-tête (`Molecules::PublicRegistry::AuthorizationHeaderComponent`).
#
# Un champ vide s’affiche « Non renseigné », en gris. L’API ou le service et les données
# demandées s’affichent en codes, comme dans le fichier open data, et se coupent à la ligne quand
# ils sont trop longs (classe `r-code`).
class Molecules::PublicRegistry::AuthorizationFieldsComponentPreview < ApplicationPreview
  # @label 1. Huit champs renseignés
  #
  # Habilitation API Particulier de la Ville de Clamart.
  #
  # **Où** : fiche d’une habilitation du registre public.
  def nominal
    render Molecules::PublicRegistry::AuthorizationFieldsComponent.new(entry: clamart_entry)
  end

  # @label 2. Champs « Non renseigné »
  #
  # Cas HubEE : ni données demandées ni fondement juridique dans le fichier (DPP-224, CA2).
  #
  # **Où** : fiche d’une habilitation du registre public.
  def not_provided
    render Molecules::PublicRegistry::AuthorizationFieldsComponent.new(
      entry: clamart_entry(service: 'HubEECertDC', scopes: [], legal_basis: nil)
    )
  end

  # @label 3. Beaucoup de données demandées
  #
  # Une vingtaine de codes, séparés par des virgules, qui passent sur plusieurs lignes.
  #
  # **Où** : fiche d’une habilitation du registre public.
  def many_scopes
    render Molecules::PublicRegistry::AuthorizationFieldsComponent.new(entry: clamart_entry(scopes: many_scope_codes))
  end

  # @label 4. Code long sans espace
  #
  # `cnav_participation_familiale_eaje_parametres_calcul` et
  # `APIGFEEchangeEditeursRestauration` se coupent à la ligne au lieu de faire défiler la page à
  # 375 px (`overflow-wrap: anywhere`).
  #
  # **Où** : fiche d’une habilitation du registre public.
  def long_code
    render Molecules::PublicRegistry::AuthorizationFieldsComponent.new(
      entry: clamart_entry(service: 'APIGFEEchangeEditeursRestauration', scopes: %w[cnav_participation_familiale_eaje_parametres_calcul])
    )
  end

  private

  def clamart_entry(**overrides)
    Molecules::PublicRegistry::AuthorizationEntry.new(
      denomination: 'Ville de Clamart',
      siret: '21920023500014',
      service: 'APIParticulier',
      provider: 'DINUM',
      scopes: %w[cnaf_quotient_familial cnaf_allocataires cnaf_enfants],
      legal_basis: 'Code de l’action sociale et des familles, article L. 123-5',
      validated_on: Date.new(2026, 7, 2),
      number: 'H44120',
      **overrides
    )
  end

  def many_scope_codes
    %w[
      cnaf_quotient_familial cnaf_allocataires cnaf_enfants cnaf_adresse
      cnav_participation_familiale_eaje_allocataires cnav_participation_familiale_eaje_enfants
      cnav_participation_familiale_eaje_adresse cnav_participation_familiale_eaje_parametres_calcul
      cnous_statut_boursier cnous_echelon_bourse cnous_email cnous_identite cnous_ine
      cnous_periode_versement cnous_ville_etudes men_statut_boursier men_echelon_bourse
      men_regime_pensionnat men_statut_scolarite men_statut_etablissement
    ]
  end
end
