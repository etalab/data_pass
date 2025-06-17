class AuthorizationRequest::APICaptchEtat < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos

  add_attribute :cadre_juridique_nature
  add_documents :cadre_juridique_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
  add_attribute :cadre_juridique_url

  validates :cadre_juridique_url, format: { with: %r{\A((http|https)://)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[\w\-._~:\/?#\[\]@!$&'()*+,;%=]*)?\z}, message: I18n.t('activemodel.errors.messages.url_format') }, allow_blank: true, if: -> { need_complete_validation?(:legal) }

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  def cadre_juridique_document_or_cadre_juridique_url_present
    nil
  end
end
