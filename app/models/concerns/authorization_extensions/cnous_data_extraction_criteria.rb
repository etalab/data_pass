module AuthorizationExtensions::CnousDataExtractionCriteria
  extend ActiveSupport::Concern

  ECHELONS = %w[0Bis 1 2 3 4 5 6 7].freeze

  included do
    add_attribute :manual_code_insee_communes, type: :array
    add_attribute :echelon_bourse
    add_attribute :premiere_date_transmission

    with_options if: -> { need_complete_validation?(:cnous_data_extraction_criteria) } do
      validate :geographic_perimeter_present
      validates :echelon_bourse, presence: true, inclusion: { in: ECHELONS }
      validates :premiere_date_transmission, presence: true
    end
  end

  AUTOMATIC_LEGAL_CATEGORIES = %i[commune dept region].freeze

  def available_echelons
    self.class::ECHELONS
  end

  # The org's own geographic identity (commune/dept/region), inferred from its
  # INSEE identity rather than stored — so it can never drift from the org.
  def geographic_entity
    return @geographic_entity if defined?(@geographic_entity)

    @geographic_entity = (organization && OrganizationPerimeterDeriver.new(organization).call) || {}
  rescue GeoAPIGouvClient::ServerError
    @geographic_entity = {}
  end

  def entity_type
    geographic_entity[:entity_type]
  end

  def code_insee_entity
    geographic_entity[:code_insee_entity]
  end

  def geographic_perimeter
    [code_insee_entity].compact + manual_code_insee_communes
  end

  def geographic_perimeter_automatic?
    organization.legal_category.in?(AUTOMATIC_LEGAL_CATEGORIES) && geographic_perimeter.present?
  end

  def geographic_perimeter_declaration
    return if entity_type.blank? || code_insee_entity.blank?

    { type: entity_type, code: code_insee_entity }
  end

  private

  def geographic_perimeter_present
    return if geographic_perimeter.present?

    errors.add(:manual_code_insee_communes, :blank)
  end
end
