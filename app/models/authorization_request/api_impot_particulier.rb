class AuthorizationRequest::APIImpotParticulier < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::OperationalAcceptance
  include AuthorizationExtensions::SafetyCertification
  include AuthorizationExtensions::Volumetrie

  VOLUMETRIES = {
    '50 appels / minute': 50,
    '200 appels / minute': 200,
    '1000 appels / minute': 1000,
  }.freeze

  MANDATORY_REVENUE_YEARS = %w[
    dgfip_annee_n_moins_1
    dgfip_annee_n_moins_2
    dgfip_annee_n_moins_3
    dgfip_annee_n_moins_2_si_indispo_n_moins_1
  ].freeze

  EXCLUSIVE_REVENUE_YEARS = [
    %w[dgfip_annee_n_moins_2_si_indispo_n_moins_1],
    %w[dgfip_annee_n_moins_1 dgfip_annee_n_moins_2 dgfip_annee_n_moins_3]
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

  validate :revenue_years_selection, if: -> { need_complete_validation?(:scopes) }
  validate :revenue_years_scopes_compatibility, if: -> { need_complete_validation?(:scopes) }
  validate :scopes_compatibility, if: -> { need_complete_validation?(:scopes) }

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  private

  def revenue_years_selection
    return if scopes.intersect?(MANDATORY_REVENUE_YEARS)

    errors.add(:scopes, :invalid, message: 'sont invalides : Vous devez cocher au moins une année de revenus souhaitée avant de continuer')
  end

  def revenue_years_scopes_compatibility
    return unless scope_exists_in_each_arrays?(*EXCLUSIVE_REVENUE_YEARS)

    errors.add(:scopes, :invalid, message: "sont invalides : Vous ne pouvez pas sélectionner la donnée 'avant dernière année de revenu, si la dernière année de revenu est indisponible' avec d'autres années de revenus")
  end

  def scopes_compatibility
    return unless scope_exists_in_each_arrays?(*INCOMPATIBLE_SCOPES)

    errors.add(:scopes, :invalid, message: 'sont invalides : Des données incompatibles entre elles ont été cochées. Pour connaître les modalités d’appel et de réponse de l’API Impôt particulier ainsi que les données proposées, vous pouvez consulter le guide de présentation de cette API dans la rubrique « Les données nécessaires > Comment choisir les données »')
  end

  def scope_exists_in_each_arrays?(array_1, array_2)
    scopes.intersect?(array_1) && scopes.intersect?(array_2)
  end
end
