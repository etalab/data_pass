class AuthorizationRequest::Resana < AuthorizationRequest
  NATURES_JURIDIQUES = %w[
    administration_centrale
    service_deconcentre
    etablissement_public_administratif
    etablissement_public_scientifique_culturel_professionnel
    autre
  ].freeze

  add_attribute :nature_juridique
  add_attribute :organisations_resana
  add_attribute :habilitation_certifiee, type: :boolean
  add_documents :lettre_habilitation_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  with_options if: -> { need_complete_validation?(:legal) } do
    validates :nature_juridique, presence: true, inclusion: { in: NATURES_JURIDIQUES, allow_blank: true }
    validates :organisations_resana, presence: true
    validate :habilitation_certifiee_or_lettre_habilitation_document_present
  end

  contact :delegue_protection_donnees,
    validation_condition: ->(record) { record.need_complete_validation?(:contacts) },
    options: { except: %w[job_title] }

  contact :contact_metier,
    validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  validates :delegue_protection_donnees_phone_number, :contact_metier_phone_number,
    french_phone_number: true,
    if: -> { need_complete_validation?(:contacts) }

  private

  def habilitation_certifiee_or_lettre_habilitation_document_present
    return if habilitation_certifiee || lettre_habilitation_document.attached?

    errors.add(:habilitation_certifiee, :certification_or_letter_missing)
    errors.add(:lettre_habilitation_document, :certification_or_letter_missing)
  end
end
