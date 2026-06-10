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

    before_create :populate_codes_insee_and_entity

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
    kind = geographic_kind
    return if kind.nil?

    code = code_insee_entity_for(kind)
    return if code.nil?

    data['entity_type'] = kind
    data['code_insee_entity'] = code
  end

  def geographic_kind
    GEOGRAPHIC_KINDS[organization&.insee_payload&.dig('etablissement', 'uniteLegale', 'categorieJuridiqueUniteLegale')]
  end

  def code_insee_entity_for(kind)
    code_commune = organization.insee_payload.dig('etablissement', 'adresseEtablissement', 'codeCommuneEtablissement')
    return code_commune if kind == 'commune'
    return if code_commune.nil?

    commune = GeoAPIGouvClient.new.get("/communes/#{code_commune}", fields: 'nom,codeDepartement,codeRegion')
    return if commune.nil?

    kind == 'departement' ? commune['codeDepartement'] : commune['codeRegion']
  end

  def geographic_perimeter_present
    return if geographic_kind.present?
    return if manual_code_insee_communes.present?

    errors.add(:manual_code_insee_communes, :blank)
  end
end
