module DGFIPExtensions::APIImpotParticulierScopes
  extend ActiveSupport::Concern

  MANDATORY_REVENUE_YEARS = %w[
    dgfip_annee_n_moins_1
    dgfip_annee_n_moins_2
    dgfip_annee_n_moins_3
    dgfip_annee_n_moins_2_si_indispo_n_moins_1
  ].freeze

  INCOMPATIBLE_SCOPES = [
    %w[dgfip_annee_n_moins_2_si_indispo_n_moins_1 dgfip_annee_df_au_3112_si_deces_ctb_mp],
    %w[
      dgfip_indiIFI dgfip_RevDecl_Cat1_Tspr dgfip_RevDecl_Cat5_NonSal
      dgfip_RevNets_Cat1_Tspr dgfip_RevNets_Cat1_RentOn dgfip_RevNets_Cat2_Rcm
      dgfip_RevNets_Cat3_PMV dgfip_RevNets_Cat4_Ref dgfip_RevNets_Cat5_NonSal
      dgfip_PaDeduc_EnfMaj dgfip_PaDeduc_Autres dgfip_EpargRetrDeduc dgfip_IndLep
    ]
  ].freeze

  included do
    add_attributes :specific_requirements

    add_document :specific_requirements_document, content_type: %w[
      application/vnd.oasis.opendocument.spreadsheet
      application/vnd.ms-excel
      application/vnd.sun.xml.calc
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      text/csv
    ], size: { less_than: 10.megabytes }

    validate :at_least_one_revenue_year_has_been_selected, if: -> { need_complete_validation?(:scopes) && !specific_requirements? }
    validate :revenue_years_scopes_compatibility, if: -> { need_complete_validation?(:scopes) && !specific_requirements? }
    validate :scopes_compatibility, if: -> { need_complete_validation?(:scopes) && !specific_requirements? }
    validate :specific_requirements_document_presence, if: -> { specific_requirements? && need_complete_validation?(:scopes) }
  end

  private

  def at_least_one_revenue_year_has_been_selected
    return if scopes.intersect?(MANDATORY_REVENUE_YEARS)

    errors.add(:scopes, :invalid, message: 'sont invalides : Vous devez cocher au moins une année de revenus souhaitée avant de continuer')
  end

  def revenue_years_scopes_compatibility
    return unless scopes.include?('dgfip_annee_n_moins_2_si_indispo_n_moins_1')
    return unless scopes.intersect?(%w[dgfip_annee_n_moins_1 dgfip_annee_n_moins_2 dgfip_annee_n_moins_3])

    errors.add(:scopes, :invalid, message: "sont invalides : Vous ne pouvez pas sélectionner la donnée 'avant dernière année de revenu, si la dernière année de revenu est indisponible' avec d'autres années de revenus")
  end

  def scopes_compatibility
    return unless scope_exists_in_each_arrays?(*INCOMPATIBLE_SCOPES)

    errors.add(:scopes, :invalid, message: 'sont invalides : Des données incompatibles entre elles ont été cochées. Pour connaître les modalités d’appel et de réponse de l’API Impôt particulier ainsi que les données proposées, vous pouvez consulter le guide de présentation de cette API dans la rubrique « Les données nécessaires > Comment choisir les données »')
  end

  def scope_exists_in_each_arrays?(array_1, array_2)
    scopes.intersect?(array_1) && scopes.intersect?(array_2)
  end

  def specific_requirements_document_presence
    return if specific_requirements_document.present?

    errors.add(:specific_requirements_document, message: 'est manquant : vous devez ajoutez un fichier avant de passer à l’étape suivante')
  end

  def specific_requirements?
    specific_requirements == '1'
  end
end
