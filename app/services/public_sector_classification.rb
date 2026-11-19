class PublicSectorClassification
  CLOSED_ADMINISTRATIVE_STATE = 'C'.freeze
  PUBLIC_REASONS = %i[public_legal_category whitelisted_siren].freeze

  def self.data
    @data ||= YAML.load_file(Rails.root.join('config/public_sector_classification.yml')).freeze
  end

  def initialize(organization)
    @unite_legale = organization.insee_payload.dig('etablissement', 'uniteLegale') || {}
    @siren = organization.siret.to_s.first(9)
  end

  def known?
    legal_category.present?
  end

  def public?
    PUBLIC_REASONS.include?(reason)
  end

  def private?
    known? && !public?
  end

  def reason
    return :unknown_legal_category unless known?
    return :blacklisted_siren if listed?('blacklisted_sirens')
    return :closed_unit if closed?
    return :whitelisted_siren if listed?('whitelisted_sirens')

    public_legal_category? ? :public_legal_category : :private_legal_category
  end

  private

  def legal_category
    @unite_legale['categorieJuridiqueUniteLegale'].to_s
  end

  def closed?
    @unite_legale['etatAdministratifUniteLegale'] == CLOSED_ADMINISTRATIVE_STATE
  end

  def public_legal_category?
    self.class.data.fetch('legal_categories').include?(legal_category)
  end

  def listed?(list)
    self.class.data.fetch(list).include?(@siren)
  end
end
