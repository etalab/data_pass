module AuthorizationExtensions::CadreJuridique
  extend ActiveSupport::Concern

  included do
    add_document :cadre_juridique_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
    add_attribute :cadre_juridique_url

    validate :cadre_juridique_document_or_cadre_juridique_url_present, if: -> { need_complete_validation?(:legal) }

    add_attribute :cadre_juridique_nature
    validates :cadre_juridique_nature, presence: true, if: -> { need_complete_validation?(:legal) }
  end

  def cadre_juridique_document_or_cadre_juridique_url_present
    return if cadre_juridique_document.present? || cadre_juridique_url.present?

    errors.add(:cadre_juridique_document, :blank)
    errors.add(:cadre_juridique_url, :blank)
  end
end
