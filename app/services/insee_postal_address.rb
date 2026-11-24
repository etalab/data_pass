class INSEEPostalAddress
  STREET_TYPES = {
    'ALL' => 'allée', 'AV' => 'avenue', 'BD' => 'boulevard', 'CAR' => 'carrefour', 'CHE' => 'chemin',
    'CHS' => 'chaussée', 'CITE' => 'cité', 'COR' => 'corniche', 'CRS' => 'cours', 'DOM' => 'domaine',
    'DSC' => 'descente', 'ECA' => 'écart', 'ESP' => 'esplanade', 'FG' => 'faubourg', 'GR' => 'grande rue',
    'HAM' => 'hameau', 'HLE' => 'halle', 'IMP' => 'impasse', 'LD' => 'lieu-dit', 'LOT' => 'lotissement',
    'MAR' => 'marché', 'MTE' => 'montée', 'PASS' => 'passage', 'PL' => 'place', 'PLN' => 'plaine',
    'PLT' => 'plateau', 'PRO' => 'promenade', 'PRV' => 'parvis', 'QUA' => 'quartier', 'QUAI' => 'quai',
    'RES' => 'résidence', 'RLE' => 'ruelle', 'ROC' => 'rocade', 'RPT' => 'rond-point', 'RTE' => 'route',
    'RUE' => 'rue', 'SEN' => 'sentier', 'SQ' => 'square', 'TPL' => 'terre-plein', 'TRA' => 'traverse',
    'VLA' => 'villa', 'VLGE' => 'village'
  }.freeze
  LOWERCASE_WORDS = %w[à au aux d de des du en et l la le les sous sur].freeze
  WITHHELD_VALUE = '[ND]'.freeze

  def initialize(address_payload)
    @address_payload = address_payload || {}
  end

  def to_s
    [street, town].compact_blank.join(', ')
  end

  def known?
    address_payload.values.exclude?(WITHHELD_VALUE) && town_known?
  end

  private

  attr_reader :address_payload

  def street
    street_type = address_payload['typeVoieEtablissement'].to_s
    street_type = STREET_TYPES.fetch(street_type.upcase, street_type.downcase)

    [address_payload['numeroVoieEtablissement'], street_type.presence, name_case(address_payload['libelleVoieEtablissement'], capitalize_first: street_type.blank?)].compact_blank.join(' ')
  end

  def town
    [address_payload['codePostalEtablissement'], name_case(address_payload['libelleCommuneEtablissement'], capitalize_first: true)].compact_blank.join(' ')
  end

  def town_known?
    address_payload['codePostalEtablissement'].present? && address_payload['libelleCommuneEtablissement'].present?
  end

  def name_case(text, capitalize_first:)
    parts = text.to_s.downcase.split(/([\s-])/)

    parts.each_with_index.map { |part, index| part_case(part, capitalize: capitalize_first && index.zero?) }.join
  end

  def part_case(part, capitalize:)
    capitalize || LOWERCASE_WORDS.exclude?(part) ? part.capitalize : part
  end
end
