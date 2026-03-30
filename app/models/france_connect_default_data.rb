class FranceConnectDefaultData
  FC_EIDAS = 'eidas_1'.freeze
  FC_CADRE_JURIDIQUE_NATURE = 'Arrêté du 8 novembre 2018'.freeze
  FC_CADRE_JURIDIQUE_URL = 'https://www.legifrance.gouv.fr/loda/id/JORFTEXT000037611479'.freeze

  def self.assign_to(authorization_request)
    new(authorization_request).call
  end

  def self.attributes
    {
      fc_eidas: FC_EIDAS,
      fc_cadre_juridique_nature: FC_CADRE_JURIDIQUE_NATURE,
      fc_cadre_juridique_url: FC_CADRE_JURIDIQUE_URL
    }
  end

  def self.scope_values
    @scope_values ||= AuthorizationRequest::APIParticulier.definition.scopes
      .select { |s| s.group == 'FranceConnect' }
      .map(&:value)
  end

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def call
    assign_attributes
    assign_scopes
  end

  private

  def assign_attributes
    self.class.attributes.each do |attr, value|
      @authorization_request.public_send(:"#{attr}=", value) if @authorization_request.public_send(attr).blank?
    end
  end

  def assign_scopes
    current = @authorization_request.scopes || []
    missing = self.class.scope_values - current
    @authorization_request.scopes = (current + missing) if missing.any?
  end
end
