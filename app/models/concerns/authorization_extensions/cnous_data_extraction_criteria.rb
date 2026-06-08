module AuthorizationExtensions::CnousDataExtractionCriteria
  extend ActiveSupport::Concern

  ECHELONS = %w[0Bis 1 2 3 4 5 6 7].freeze

  GEOGRAPHIC_KINDS = {
    '7210' => 'commune',
    '7220' => 'departement',
    '7230' => 'region',
  }.freeze

  included do
    add_attribute :manual_code_insee_communes, type: :array
    add_attribute :echelon_bourse
    add_attribute :premiere_date_transmission

    after_commit :populate_codes_insee_and_entity, on: :create

    with_options if: -> { need_complete_validation?(:cnous_data_extraction_criteria) } do
      validate :geographic_perimeter_present
      validates :echelon_bourse, presence: true, inclusion: { in: ECHELONS }
      validates :premiere_date_transmission, presence: true
    end
  end

  def available_echelons
    self.class::ECHELONS
  end

  def geographic_perimeter_automatic?
    data['entity_type'].present?
  end

  private

  def populate_codes_insee_and_entity
    return if data['entity_type'].present?
    return unless organization

    kind = geographic_kind
    return if kind.nil?

    code = code_insee_entity_for(kind)
    return if code.nil?

    update_columns(data: data.merge('entity_type' => kind, 'code_insee_entity' => code)) # rubocop:disable Rails/SkipsModelValidations
  rescue GeoAPIGouvClient::ServerError, Faraday::Error
    nil
  end

  def geographic_kind
    GEOGRAPHIC_KINDS[organization.insee_payload.dig('etablissement', 'uniteLegale', 'categorieJuridiqueUniteLegale')]
  end

  def code_insee_entity_for(kind)
    code_commune = organization.insee_payload.dig('etablissement', 'adresseEtablissement', 'codeCommuneEtablissement')
    return code_commune if kind == 'commune'
    return if code_commune.nil?

    commune = GeoAPIGouvClient.new.commune(code_commune)
    return if commune.nil?

    kind == 'departement' ? commune[:code_departement] : commune[:code_region]
  end

  def geographic_perimeter_present
    return if data['entity_type'].present? || manual_code_insee_communes.present?

    errors.add(:manual_code_insee_communes, :blank)
  end
end
