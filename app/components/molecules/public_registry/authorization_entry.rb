Molecules::PublicRegistry::AuthorizationEntry = Data.define(
  :number,
  :denomination,
  :service,
  :provider,
  :validated_on,
  :siret,
  :scopes,
  :legal_basis
) do
  def initialize(siret: nil, scopes: [], legal_basis: nil, **)
    super(siret:, scopes: Array(scopes), legal_basis:, **)
  end
end
