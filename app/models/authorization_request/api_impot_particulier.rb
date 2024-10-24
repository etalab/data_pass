class AuthorizationRequest::APIImpotParticulier < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::OperationalAcceptance
  include AuthorizationExtensions::SafetyCertification

  validate :validate_revenue_years_selection

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  add_document :specific_requirements_document, content_type: %w[application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet], size: { less_than: 10.megabytes }
  add_attributes :specific_requirements, validation: { presence: true, if: -> { specific_requirements_document.present? } }

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  private

  def validate_revenue_years_selection
    selected_years = %w[
      dgfip_annee_n_moins_1 dgfip_annee_n_moins_2 dgfip_annee_n_moins_3
      dgfip_annee_n_moins_2_si_indispo_n_moins_1
    ]

    return unless (scopes & selected_years).empty?

    errors.add(:scopes, :invalid, message: "sont invalides : Vous devez cocher au moins une année de revenus souhaitée avant de continuer")
  end
end
