class IdentitySources::SireneNames
  LEGAL_UNIT_FIELDS = {
    denomination: %w[denominationUniteLegale],
    sigle: %w[sigleUniteLegale],
    usual_name: %w[denominationUsuelle1UniteLegale denominationUsuelle2UniteLegale denominationUsuelle3UniteLegale],
  }.freeze
  ESTABLISHMENT_FIELDS = {
    usual_name: %w[denominationUsuelleEtablissement],
    enseigne: %w[enseigne1Etablissement enseigne2Etablissement enseigne3Etablissement],
  }.freeze
  KINDS = %i[denomination sigle usual_name enseigne].freeze

  def self.normalize(text)
    I18n.transliterate(text.to_s).downcase.gsub(/[^a-z0-9]/, '')
  end

  def initialize(organization)
    @payload = organization&.insee_payload || {}
  end

  def normalized_by_kind
    KINDS.index_with { |kind| names_of(kind).map { |name| self.class.normalize(name) }.compact_blank.uniq }
  end

  def kind_of(name)
    normalized_name = self.class.normalize(name)
    return if normalized_name.blank?

    normalized_by_kind.find { |_kind, names| names.include?(normalized_name) }&.first
  end

  private

  attr_reader :payload

  def names_of(kind)
    LEGAL_UNIT_FIELDS.fetch(kind, []).map { |field| legal_unit[field] } +
      ESTABLISHMENT_FIELDS.fetch(kind, []).map { |field| current_establishment_period[field] }
  end

  def legal_unit
    payload.dig('etablissement', 'uniteLegale') || {}
  end

  def current_establishment_period
    periods = payload.dig('etablissement', 'periodesEtablissement') || []

    periods.find { |period| period['dateFin'].nil? } || {}
  end
end
