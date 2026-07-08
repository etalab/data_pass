module AuthorizationExtensions::CadreJuridiqueDinum
  extend ActiveSupport::Concern

  included do
    add_documents :cadre_juridique_dinum_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }, if: -> { need_complete_validation?(:legal_dinum) }
    add_attribute :cadre_juridique_dinum_url

    validate :cadre_juridique_dinum_document_or_cadre_juridique_dinum_url_present, if: -> { need_complete_validation?(:legal_dinum) }

    add_attribute :cadre_juridique_dinum_nature

    validates :cadre_juridique_dinum_nature, presence: true, if: -> { need_complete_validation?(:legal_dinum) }
    validates :cadre_juridique_dinum_url, format: { with: %r{\A((http|https)://)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[\w\-._~:/?#\[\]@!$&'()*+,;%=]*)?\z}, message: I18n.t('activemodel.errors.messages.url_format') }, allow_blank: true, if: -> { need_complete_validation?(:legal_dinum) }
  end

  def cadre_juridique_dinum_document_or_cadre_juridique_dinum_url_present
    return if cadre_juridique_dinum_document.attached? || cadre_juridique_dinum_url.present?

    errors.add(:cadre_juridique_dinum_document, :blank)
    errors.add(:cadre_juridique_dinum_url, :blank)
  end
end
