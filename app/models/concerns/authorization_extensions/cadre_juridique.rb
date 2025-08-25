module AuthorizationExtensions::CadreJuridique
  extend ActiveSupport::Concern

  included do
    add_documents :cadre_juridique_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }, if: -> { need_complete_validation?(:legal) }
    add_attribute :cadre_juridique_url

    validate :cadre_juridique_document_or_cadre_juridique_url_present, if: -> { need_complete_validation?(:legal) }

    add_attribute :cadre_juridique_nature

    validates :cadre_juridique_nature, presence: true, if: -> { need_complete_validation?(:legal) }
    validates :cadre_juridique_url, format: { with: %r{\A((http|https)://)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[\w\-._~:/?#\[\]@!$&'()*+,;%=]*)?\z}, message: I18n.t('activemodel.errors.messages.url_format') }, allow_blank: true, if: -> { need_complete_validation?(:legal) }
  end

  def cadre_juridique_document_or_cadre_juridique_url_present
    return if cadre_juridique_document.attached? || cadre_juridique_url.present?

    errors.add(:cadre_juridique_document, :blank)
    errors.add(:cadre_juridique_url, :blank)
  end
end
