class PrefillGeographicPerimeter
  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def call
    return if @authorization_request.entity_type.present?
    return unless @authorization_request.organization

    declaration = OrganizationPerimeterDeriver.new(@authorization_request.organization).call
    return if declaration.blank?

    persist(declaration)
  rescue GeoAPIGouvClient::ServerError, Faraday::Error
    nil
  end

  private

  def persist(declaration)
    @authorization_request.update_columns( # rubocop:disable Rails/SkipsModelValidations
      data: @authorization_request.data.merge(
        'entity_type' => declaration[:entity_type],
        'code_insee_entity' => declaration[:code_insee_entity]
      )
    )
  end
end
