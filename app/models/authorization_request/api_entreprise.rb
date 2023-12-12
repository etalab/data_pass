class AuthorizationRequest::APIEntreprise < AuthorizationRequest
  %i[
    intitule
    description
  ].each do |attr|
    add_attribute attr

    validates attr, presence: true, if: -> { need_complete_validation?(:basic_infos) }
  end

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  %i[
    destinataire_donnees_caractere_personnel
    duree_conservation_donnees_caractere_personnel
  ].each do |attr|
    add_attribute attr
    validates attr, presence: true, if: -> { need_complete_validation?(:personal_data) }
  end

  add_scopes
  validates :scopes, presence: true, if: -> { need_complete_validation?(:scopes) }

  add_document :cadre_juridique_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
  add_attribute :cadre_juridique_url

  validate :cadre_juridique_document_or_cadre_juridique_url_present, if: -> { need_complete_validation?(:legal) }

  def cadre_juridique_document_or_cadre_juridique_url_present
    return if cadre_juridique_document.present? || cadre_juridique_url.present?

    errors.add(:cadre_juridique_document, :blank)
    errors.add(:cadre_juridique_url, :blank)
  end

  add_attribute :cadre_juridique_nature
  validates :cadre_juridique_nature, presence: true, if: -> { need_complete_validation?(:legal) }

  %i[
    responsable_traitement
    delegue_protection_donnees
    contact_metier
    contact_technique
  ].each do |contact_kind|
    contact contact_kind, validation_condition: -> { need_complete_validation?(:contacts) }
  end
end
