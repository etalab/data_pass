module AuthorizationExtensions::FranceConnectEmbeddedFields
  extend ActiveSupport::Concern

  FRANCE_CONNECT_GROUP = 'FranceConnect'.freeze

  included do
    add_attribute :fc_cadre_juridique_nature
    add_attribute :fc_cadre_juridique_url
    add_documents :fc_cadre_juridique_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }, if: -> { embeds_france_connect_fields? && need_complete_validation?(:legal) }

    validate :fc_cadre_juridique_document_or_fc_cadre_juridique_url_present, if: -> { embeds_france_connect_fields? && need_complete_validation?(:legal) }
    validates :fc_cadre_juridique_nature, presence: true, if: -> { embeds_france_connect_fields? && need_complete_validation?(:legal) }
    validates :fc_cadre_juridique_url, format: { with: %r{\A((http|https)://)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[\w\-._~:/?#\[\]@!$&'()*+,;%=]*)?\z}, message: I18n.t('activemodel.errors.messages.url_format') }, allow_blank: true, if: -> { embeds_france_connect_fields? && need_complete_validation?(:legal) }

    add_attribute :fc_alternative_connexion
    add_attribute :fc_eidas

    validate :france_connect_scopes_must_be_complete,
      if: -> { embeds_france_connect_fields? && need_complete_validation?(:scopes) }
  end

  def france_connect_modality?
    modalities&.include?('france_connect')
  end

  def fc_scopes
    return [] if scopes.blank?

    Array(scopes) & france_connect_scope_values
  end

  def france_connect_attributes
    return {} unless france_connect_modality?

    france_connect_core_attributes
      .merge(common_attributes_for_france_connect)
      .merge(france_connect_contacts_attributes)
  end

  def attach_documents_to_france_connect_authorization(france_connect_authorization)
    return unless fc_cadre_juridique_document.attached?

    fc_cadre_juridique_document.each do |file|
      france_connect_authorization.cadre_juridique_document.attach(file.blob)
    end
  end

  private

  def fc_cadre_juridique_document_or_fc_cadre_juridique_url_present
    return if fc_cadre_juridique_document.attached? || fc_cadre_juridique_url.present?

    errors.add(:fc_cadre_juridique_document, :blank)
    errors.add(:fc_cadre_juridique_url, :blank)
  end

  def france_connect_scopes_must_be_complete
    missing_scopes = france_connect_scope_values - scopes

    return if missing_scopes.empty?

    errors.add(:scopes, :incomplete_france_connect_scopes)
  end

  def france_connect_scope_values
    self.class.definition.scopes
      .select { |scope| scope.group == FRANCE_CONNECT_GROUP }
      .map(&:value)
  end

  def france_connect_core_attributes
    {
      cadre_juridique_nature: fc_cadre_juridique_nature,
      cadre_juridique_url: fc_cadre_juridique_url,
      scopes: fc_scopes,
      france_connect_eidas: fc_eidas,
      alternative_connexion: fc_alternative_connexion,
      destinataire_donnees_caractere_personnel:,
      duree_conservation_donnees_caractere_personnel:,
      duree_conservation_donnees_caractere_personnel_justification:,
      date_prevue_mise_en_production:,
      volumetrie_approximative:
    }
  end

  def france_connect_contacts_attributes
    contact_for(:contact_technique).to_attributes(prefix: :contact_technique)
      .merge(contact_for(:contact_metier).to_attributes(prefix: :responsable_traitement))
      .merge(contact_for(:delegue_protection_donnees).to_attributes(prefix: :delegue_protection_donnees))
  end

  def contact_for(type)
    Contact.new(type, self)
  end

  def common_attributes_for_france_connect
    {
      organization_id:,
      applicant_id:,
      intitule:,
      description:
    }
  end
end
