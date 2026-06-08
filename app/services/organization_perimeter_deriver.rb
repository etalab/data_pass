class OrganizationPerimeterDeriver
  def initialize(organization, client: GeoAPIGouvClient.new)
    @organization = organization
    @client = client
  end

  def call
    case @organization.legal_category
    when :commune
      commune_code && { entity_type: 'commune', code_insee_entity: commune_code }
    when :dept
      resolved_commune && { entity_type: 'departement', code_insee_entity: resolved_commune[:code_departement] }
    when :region
      resolved_commune && { entity_type: 'region', code_insee_entity: resolved_commune[:code_region] }
    end
  end

  private

  def commune_code
    @organization.insee_payload.dig('etablissement', 'adresseEtablissement', 'codeCommuneEtablissement')
  end

  def resolved_commune
    return @resolved_commune if defined?(@resolved_commune)

    @resolved_commune = commune_code ? @client.commune(commune_code) : nil
  end
end
