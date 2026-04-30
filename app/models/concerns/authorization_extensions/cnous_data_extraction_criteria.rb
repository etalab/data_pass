module AuthorizationExtensions::CnousDataExtractionCriteria
  extend ActiveSupport::Concern

  RECURRENCE_VALUES = %w[annually biannually].freeze

  included do
    add_attribute :communes_codes_insee, type: :array
    add_attribute :echelon_bourse
    add_attribute :premiere_date_transmission
    add_attribute :recurrence

    with_options if: -> { need_complete_validation?(:cnous_data_extraction_criteria) } do
      validates :communes_codes_insee, presence: true
      validates :echelon_bourse, presence: true
      validates :premiere_date_transmission, presence: true
      validates :recurrence, presence: true, inclusion: { in: RECURRENCE_VALUES }
    end
  end
end
