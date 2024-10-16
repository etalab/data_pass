module AuthorizationExtensions::SafetyCertification
  extend ActiveSupport::Concern

  included do
    add_document :safety_certification_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
    add_attribute :safety_certification_authority_name
    add_attribute :safety_certification_authority_function
    add_attribute :safety_certification_begin_date
    add_attribute :safety_certification_end_date

    validates :safety_certification_document,
      :safety_certification_authority_name,
      :safety_certification_authority_function,
      :safety_certification_begin_date,
      :safety_certification_end_date,
      presence: true,
      if: -> { need_complete_validation?(:safety_certification) }
  end
end
