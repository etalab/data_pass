module AuthorizationExtensions::CnousDataExtractionCriteria
  extend ActiveSupport::Concern

  ECHELONS = %w[0Bis 1 2 3 4 5 6 7].freeze

  included do
    add_attribute :manual_code_insee_communes, type: :array
    add_attribute :echelon_bourse
    add_attribute :premiere_date_transmission

    after_commit :prefill_geographic_perimeter, on: :create

    with_options if: -> { need_complete_validation?(:cnous_data_extraction_criteria) } do
      validate :geographic_perimeter_present
      validates :echelon_bourse, presence: true, inclusion: { in: ECHELONS }
      validates :premiere_date_transmission, presence: true
    end
  end

  def available_echelons
    self.class::ECHELONS
  end

  # Geographic identity (commune/dept/region) derived once from the org's INSEE
  # identity at creation and persisted: trusted server-side data, never user-set
  # (kept out of extra_attributes so it cannot be mass-assigned from form params).
  def entity_type
    data['entity_type'].presence
  end

  def code_insee_entity
    data['code_insee_entity'].presence
  end

  def geographic_perimeter
    [code_insee_entity].compact + manual_code_insee_communes
  end

  def geographic_perimeter_automatic?
    entity_type.present?
  end

  def geographic_perimeter_declaration
    return if entity_type.blank? || code_insee_entity.blank?

    { type: entity_type, code: code_insee_entity }
  end

  private

  def prefill_geographic_perimeter
    PrefillGeographicPerimeter.new(self).call
  end

  def geographic_perimeter_present
    return if geographic_perimeter.present?

    errors.add(:manual_code_insee_communes, :blank)
  end
end
