module AuthorizationExtensions::CnousDataExtractionCriteria
  extend ActiveSupport::Concern

  ECHELONS = %w[0Bis 1 2 3 4 5 6 7].freeze

  included do
    add_attribute :communes_codes_insee, type: :array
    add_attribute :echelon_bourse
    add_attribute :premiere_date_transmission

    with_options if: -> { need_complete_validation?(:cnous_data_extraction_criteria) } do
      validates :communes_codes_insee, presence: true
      validates :echelon_bourse, presence: true, inclusion: { in: ECHELONS }
      validates :premiere_date_transmission, presence: true
    end
  end

  def available_echelons
    self.class::ECHELONS
  end
end
